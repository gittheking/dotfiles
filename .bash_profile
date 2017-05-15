#  _              _                        __ _ _
# | |__  __ _ ___| |__    _ __  _ __ ___  / _(_) | ___
# | '_ \ / _` / __| '_ \  | '_ \| '__/ _ \| |_| | |/ _ \
# | |_) | (_| \__ \ | | | | |_) | | | (_) |  _| | |  __/
# |_.__/ \__,_|___/_| |_| | .__/|_|  \___/|_| |_|_|\___|
#                         |_|


# -----------------------------------------------------------------------------
# Path
# A list of all directories in which to look for commands, scripts and programs
# -----------------------------------------------------------------------------

PATH="/usr/local/bin:/usr/local/sbin:$PATH"                # Homebrew
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"       # Coreutils
MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH" # Manual pages

# =================
# Settings
# =================

# Prefer US English
export LC_ALL="en_US.UTF-8"
# use UTF-8
export LANG="en_US"

# # Adds colors to LS!!!!
# export CLICOLOR=1
# # http://geoff.greer.fm/lscolors/
# # Describes what color to use for which attribute (files, folders etc.)
# export LSCOLORS=exfxcxdxbxegedabagacad # PJ: turned off
# export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"

# =================
# History
# =================

# http://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/
# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE

# don't put duplicate lines in the history.
export HISTCONTROL=ignoredups

# ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# Make some commands not show up in history
export HISTIGNORE="h"

# ====================
# Aliases
# ====================

# LS lists information about files.
# show slashes for directories.
alias ls='ls -F'

# long list format including hidden files and include unit size
alias ll='ls -la'

# go back one directory
alias b='cd ..'

# History lists your previously entered commands
alias h='history'

# If we make a change to our bash profile we need to reload it
alias reload="clear; source ~/.bash_profile"

# confirm before executing and be verbose
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'

# =================
# Additional Aliases
# =================

# List any open internet sockets on several popular ports.
# Useful if a rogue server is running
# http://www.akadia.com/services/lsof_intro.html
# http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
alias rogue='lsof -i TCP:3000 -i TCP:4567 -i TCP:8000 -i TCP:8888 -i TCP:6379'


# ================
# Application Aliases
# ================

# Sublime should be symlinked. Otherwise use one of these
# alias subl='open -a "Sublime"'
# alias subl='open -a "Sublime Text 2"'
alias chrome='open -a "Google Chrome"'

# =================
# rbenv
# =================

# start rbenv (our Ruby environment and version manager) on open
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# =================
# node
# =================

# export NVM_DIR=$(brew --prefix)/var/nvm
# source $(brew --prefix nvm)/nvm.sh
# nvm use stable
# =================
# Functions
# =================

#######################################
# Start an HTTP server from a directory
# Arguments:
#  Port (optional)
#######################################

server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)

  # Simple Pythong Server:
  # python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"

  # Simple Ruby Webrick Server:
  ruby -e "require 'webrick';server = WEBrick::HTTPServer.new(:Port=>${port},:DocumentRoot=>Dir::pwd );trap('INT'){ server.shutdown };server.start"
}

#######################################
# Pull an individual folder from a github repo using SVN
# Arguments:
#  URL to root folder on github
# Author:
#  Philco
#######################################

function gitme() {
  local url=$1
  local pathname=$2
  # replace tree/master with trunk
  svn checkout ${url/tree\/master/trunk} $pathname
  # remove the svn folder
  if [ -z "$2" ]; then
    rm -rf "$(basename $url)/.svn"
  else
    rm -rf "$pathname/.svn"
    echo "deleting $pathname/.svn"
  fi
}

#######################################
# Create a new directory and then cd into that directory
# Arguments:
#  name of new directory
# Author:
#  Unknown
#######################################

mkcd () {
   mkdir -p "$*"
   cd "$*"
}

#######################################
# Creates a full MVC ready Sinatra application
# Arguments:
#  name of new directory
# Author:
#  John R. Bell
#######################################

sinatra_touch() {
  if (( "$#" != 1 ))
  then
      echo "You must provide a project name. Usage: 'sinatra [name]'"
      return
  fi
    mkdir $1
    cd $1
    mkdir views
      # touch views/index.erb
      echo -e '"Hello World."' > views/index.erb
      # touch views/layout.erb
      echo -e '<!doctype html>\n<html>\n<head>\n  <link href="/css/style.css" rel="stylesheet" type="text/css">\n</head>\n<body>\n  <div class="container">\n    <%= yield %>\n  </div>\n</body>\n</html>\n<script src="/js/jquery.js" type="text/javascript"></script>\n<script src="/js/script.js" type="text/javascript"></script>' > views/layout.erb
    mkdir public
      mkdir public/img
      mkdir public/css
        touch public/css/style.css
      mkdir public/js
        curl http://code.jquery.com/jquery-2.2.1.min.js > public/js/jquery.js
        # touch public/js/script.js
        echo -e '"use strict";\n(function(){\n\n})();' > public/js/script.js
    mkdir lib
    # touch server.rb
    printf 'module Sinatra\n  class Server < Sinatra::Base\n    get "/" do\n      erb :index\n    end\n  end\nend' > server.rb
    # touch config.ru
    printf 'require "sinatra/base"\nrequire "sinatra/reloader"\nrequire_relative "server"\nrun Sinatra::Server' > config.ru
    # bundle init
    subl .
}

#######################################
# Creates a linter config file
# Arguments:
#  none
# Author:
#  Bobby King
#######################################

lint_touch() {
  touch .eslintrc.js
  echo -e 'module.exports = {\n  "env": {\n    "browser": true,\n    "es6": true\n  },\n  "extends": "eslint:recommended",\n  "parserOptions": {\n    "sourceType": "module"\n  },\n  "rules": {\n    "indent": [\n      "error",\n      2\n    ],\n    "linebreak-style": [\n      "error",\n      "unix"\n    ],\n    "quotes": [\n      "error",\n      "single"\n    ],\n    "semi": [\n      "error",\n      "always"\n    ]\n  }\n};' > .eslintrc.js
}

#######################################
# Shortcuts for navigating to and switching branches
# in WDI Zoolander
# Arguments:
#  none
#######################################


killpid () {
  rm /usr/local/var/postgres/postmaster.pid
}

# =================
# Tab Improvements
# =================

## Tab improvements
# ## Might not need?
# bind 'set completion-ignore-case on'
# # make completions appear immediately after pressing TAB once
# bind 'set show-all-if-ambiguous on'
# bind 'TAB: menu-complete'

# =================
# Sourced Scripts
# =================

# Builds the prompt with git branch notifications.
if [ -f ~/.bash_prompt.sh ]; then
  source ~/.bash_prompt.sh
fi

# bash/zsh completion support for core Git.
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

