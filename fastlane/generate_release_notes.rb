require 'git'
require 'octokit'
require 'yaml'


class GenerateReleaseNotes

  def initialize(repo_name, previous_sha_file, access_token)
    return puts 'You must supply a valid github API token' unless access_token && access_token.length > 0

    @repo_name = repo_name
    @previous_sha_file = previous_sha_file
    @access_token = access_token
    @pull_request_notes = ['RELEASE NOTES']
    # Grab out previous sha
    @previous_sha_yaml = YAML::load_file(@previous_sha_file)
    @release_version = `/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "Support/Info.plist"`.strip()
    @number_of_commits = `git rev-list master | wc -l | tr -d ' '`.strip()
  end

  # add PRs from commits
  def scan_commits(commits)
    commits.each do |commit|
      return true if @previous_sha_yaml['previous-sha'] == commit.sha
      match = commit.message.match(/pull request #(\d+) from/)
      if match
        pr_num = match.captures[0]
        pr = @client.pull_request @repo_name, pr_num
        if pr[:state] == 'closed'
          @pull_request_notes << "#### ##{pr_num} - #{pr[:title]}\n#{pr[:body]}".strip()
        end
      end
    end
  end

  def create_release_notes
    # create github api client
    @client = Octokit::Client.new(access_token: @access_token)
    # create git
    @git = Git.open('./')
    commits = @git.log(100)
    @newest_sha = commits.first.sha
    # start creating the notes
    scan_commits commits

    # new release notes
    release_notes = "### Ello Build #{@release_version}(#{@number_of_commits}) #{Time.now.strftime("%B %-d, %Y")}\n\n"
    release_notes << <<-EOF
    #{@pull_request_notes.count > 1 ? @pull_request_notes.join("\n\n------\n\n") : 'No completed pull requests since last distribution.'}
    #{"\n------------\n"}
    EOF

    # add release_notes to crashlytics-release-notes
    `mkdir Build`
    File.open('Build/crashlytics-release-notes.md', 'w') { |f| f.write release_notes.gsub(/(#+ )/, "") }

    # prepend new contents into release-notes
    old = File.open('release-notes.md', 'a')
    new = File.open('release-notes.new.md', 'w')
    File.open(new, 'w') { |f|
      f.puts release_notes
      f.puts File.read(old)
    }
    File.rename(new, old)

    # update the latest commit from here
    @previous_sha_yaml["previous-sha"] = @newest_sha
    File.open(@previous_sha_file, 'w') {|f| f.write @previous_sha_yaml.to_yaml }
  end

end
