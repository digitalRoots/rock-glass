

namespace :site do
  desc "Generate the site"
  task :build do
    # check_destination
    sh "bundle exec jekyll build"
  end

  desc "Generate the site and serve locally"
  task :serve do
    # check_destination
    sh "bundle exec jekyll serve"
  end

  desc "Generate the site, serve locally and watch for changes"
  task :watch do
    sh "bundle exec jekyll serve --watch"
  end

  desc "Generate the site and push changes to remote origin"
  task :deploy do
    # Detect pull request
    if ENV['TRAVIS_PULL_REQUEST'].to_s.to_i > 0
      puts 'Pull request detected. Not proceeding with deploy.'
      exit
    end

    # Configure git if this is run in Travis CI
    if ENV["TRAVIS"]
      sh "git config --global user.name '#{ENV['GIT_NAME']}'"
      sh "git config --global user.email '#{ENV['GIT_EMAIL']}'"
      sh "git config --global push.default simple"
      # USERNAME = `printf '%s' $(cd .. && printf '%s' ${PWD##*/})`
      USERNAME = `printf '%s' $(echo $TRAVIS_REPO_SLUG | cut --fields=1 --delimiter='/')`
      # REPO = `printf '%s' $(cd . && printf '%s\n' ${PWD##*/})`
      REPO = `printf '%s' $(echo $TRAVIS_REPO_SLUG | cut --fields=2 --delimiter='/')`
    else
      USERNAME = CONFIG["username"] || ENV['GIT_NAME']
      REPO = CONFIG["repo"] || "#{USERNAME}.github.io"
    end

    # Determine source and destination branch
    # User or organization: source -> master
    # Project: master -> gh-pages
    # Name of source branch for user/organization defaults to "source"
    if REPO == "#{USERNAME}.github.io".downcase
      SOURCE_BRANCH = CONFIG['branch'] || "source"
      DESTINATION_BRANCH = "master"
    else
      SOURCE_BRANCH = "master"
      DESTINATION_BRANCH = "gh-pages"
    end

    # Make sure destination folder exists as git repo
    # check_destination
    CONFIG["destination"] = "../deploy/#{REPO}"

    puts "=== === === === === ==="
    puts "USERNAME = #{USERNAME}"
    puts "REPO = #{REPO}"
    puts "SOURCE_BRANCH = #{SOURCE_BRANCH}"
    puts "DESTINATION_BRANCH = #{DESTINATION_BRANCH}"
    puts "CONFIG[\"destination\"] = #{CONFIG["destination"]}"
    CMD = "git clone https://#{ENV['GIT_NAME']}:#{ENV['GH_TOKEN']}@github.com/#{USERNAME}/#{REPO}.git #{CONFIG["destination"]}"
    puts "CMD = #{CMD}"
    puts "git clone https://#{ENV['GIT_NAME']}:#{ENV['GH_TOKEN']}@github.com\/#{USERNAME}\/#{REPO}.git #{CONFIG["destination"]}"
    puts "=== === === === === ==="
    unless Dir.exist? CONFIG["destination"]
      sh "git clone https://#{ENV['GIT_NAME']}:#{ENV['GH_TOKEN']}@github.com/#{USERNAME}/#{REPO}.git #{CONFIG["destination"]}"
    end

    sh "git checkout #{SOURCE_BRANCH}"
    Dir.chdir(CONFIG["destination"]) { sh "git checkout #{DESTINATION_BRANCH}" }

    # Generate the site
    sh "bundle exec jekyll build"

    # Commit and push to github
    sha = `git log`.match(/[a-z0-9]{40}/)[0]
    Dir.chdir(CONFIG["destination"]) do
      sh "git add --all ."
      sh "git commit -m 'Updating to #{USERNAME}/#{REPO}@#{sha}.'"
      sh "git push --quiet origin #{DESTINATION_BRANCH}"
      puts "Pushed updated branch #{DESTINATION_BRANCH} to GitHub Pages"
    end
  end
end
