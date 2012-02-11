#!/usr/bin/env ruby

require 'json'
require 'net/https'

# of course, the whole thing can be speeded up by using github-api-gem
# but for now we go with the zero dependencies

# This uses the deprecated V2 API because that lets you use your token instead
# of entering your password all the time.
# user is the username whose repo you want to open a pull request to
# repo is the name of the repo you want to open a pull request to
def api_uri(user = nil, repo = nil)
  raise ArgumentError.new("Either none or both user and repo must be specified") if [user,repo].compact.size == 1 # not allowed to specify just one
  remote_url = `git remote show -n origin`.split("\n").grep(/Push/).first.split.grep(/github/)[0]
  user,repo = remote_url.split(':')[1].sub(/\.git$/, '').split("/")   if user.nil?
  URI.parse("https://github.com/api/v2/json/pulls/#{user}/#{repo}")
end

def current_branch
  `git symbolic-ref HEAD`.strip.sub("refs/heads/", "")
end

def current_user
  `git config github.user`.strip
end

def current_token
  `git config github.token`.strip
end

def current_repo
  /git@[a-z.:\/]*/.match(File.read(".git/config")).to_s.split("/")[1].split(".")[0] # get the repo name from .git/config
end


# if the repo is forked, gets the parent repo
def parent_repo
  return @pr if @pr
  uri = URI("https://github.com/api/v2/json/repos/show/#{current_user}/#{current_repo}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  repo_info = http.request(Net::HTTP::Get.new(uri.request_uri)).body
  @pr = JSON.parse(repo_info)["repository"]["source"]
end


# gets all the branches in the current repo
def parent_repo_branches(refresh = false)
  return @prbs if @prbs and not refresh
  uri = URI("https://github.com/api/v2/json/repos/show/#{parent_repo}/branches")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  repo_info = http.request(Net::HTTP::Get.new(uri.request_uri)).body
  @prbs = JSON.parse(repo_info)["branches"].keys
end

def remote_branches
  `git branch -r`.split("\n").reject{|b| b.match("->")}.map{|b| b.split("/")[1]}
end

# an array of all the places one can pull to
def pull_to_options
  return @pto if @pto
  to_parent = parent_repo_branches.map{|m| "#{parent_repo}:#{m}"}
  to_remote = remote_branches
  @pto = to_parent + to_remote
end

def ensure_github_token_is_set
  if current_token.empty?
    puts "Please set github.token: git config --global github.token <TOKEN>"
    exit 1
  end
end


def try_to_create_pull_request(base = @base, head = @head, title = @title)
  unless title
    print "please create a title for the pull request\nTitle:"
    title = gets.chomp
  end
  post = Net::HTTP::Post.new(api_uri.request_uri)
  post.basic_auth("#{current_user}/token", current_token)
  post.set_form_data("pull[base]" => base,
                     "pull[head]" => head,
                     "pull[title]" => title)

  http = Net::HTTP.new(api_uri.host, api_uri.port)
  http.use_ssl = true
  response = http.request(post)
  response.body
end

ensure_github_token_is_set

@base = @head = @title = nil 

# parse arguments. arguments can be
# parent:branch-name             if you want to send a pull request to the source repository OR
# branch-name                    to pull to another branch in your own repo or
#                                specify nothing to pull to master
# ?                              ask me what, where and how
pull_to = ARGV[0]
puts pull_to
if pull_to.nil? # pull to current master
  puts "pulling to master"
  @base = "master"
  @head = current_branch
elsif pull_to == "--ask"
  puts "please select a remote branch on which to open a pull request"
  pull_to_options.each_with_index do |o,i|
    puts "#{i+1} => #{o}"
  end
  chosen = gets.chomp.to_i
  if (1..pull_to_options.count).include?(chosen)
    pull_to_chosen  = pull_to_options[chosen]
    to_parent = pull_to_chosen.match(":")
    @base = to_parent ? pull_to_chosen.split(":")[1] : pull_to_chosen
    @head = to_parent ? "#{current_user}:#{current_branch}" : current_branch
  else
    puts "chosen option does not exist"
    exit 1
  end
elsif pull_to.match(":")
  pull_args = pull_to.split(":")
  if pull_args[0] == "parent"
    parent_branch = pull_args[1] || "master"
    puts "initiate pull request to #{parent_repo}:#{parent_branch} [Y/n]?"
    if ['y',''].include?(gets.chomp.downcase)
      @base = parent_branch
      @head = "#{current_user}:#{current_branch}"
    else
      exit 1
    end
  end
end  

json = JSON.parse(try_to_create_pull_request)

if json.key?('error')
  puts "ERROR:"
  puts [json['error']].flatten.join("\n")
  exit 1
else
  pull_url = json['pull']['html_url']
  puts pull_url
end
