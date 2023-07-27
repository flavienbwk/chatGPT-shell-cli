#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi
# Check dependencies
if type curl &>/dev/null; then
  echo "" &>/dev/null
else
  echo "You need to install 'curl' to use the chatgpt script."
  exit
fi
if type jq &>/dev/null; then
  echo "" &>/dev/null
else
  echo "You need to install 'jq' to use the chatgpt script."
  exit
fi

# Installing imgcat if using iTerm
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  if [[ ! $(which imgcat) ]]; then
    curl -sS https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
    chmod +x /usr/local/bin/imgcat
    echo "Installed imgcat"
  fi
fi

# Installing magick if using kitty
if [[ "$TERM" == "xterm-kitty" ]]; then
  if [[ ! $(which magick) ]]; then
    curl -sS https://imagemagick.org/archive/binaries/magick -o /usr/local/bin/magick
    chmod +x /usr/local/bin/magick
    echo "Installed magick"
  fi
fi

# Installing chatgpt script
cp ./chatgpt.sh /usr/local/bin/chatgpt

# Replace open image command with xdg-open for linux systems
if [[ "$OSTYPE" == "linux"* ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
  sed -i 's/open "\${image_url}"/xdg-open "\${image_url}"/g' '/usr/local/bin/chatgpt'
fi
chmod +x /usr/local/bin/chatgpt
echo "Installed chatgpt script to /usr/local/bin/chatgpt"

# Command to get the home directory of the user running the script behind sudo
HOME_USER=$(getent passwd $SUDO_USER | cut -d: -f6)

echo "The script will add the OPENAI_API_KEY environment variable to your shell profile and add /usr/local/bin to your PATH"
echo "Would you like to continue? (Yes/No)"
read -e answer
if [ "$answer" == "Yes" ] || [ "$answer" == "yes" ] || [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "ok" ]; then

  read -p "Please enter your OpenAI API key: " key
  read -p "Please enter the URI to open (leave empty for default OpenAI API key): " uri
  if [ "$uri" == "" ]; then
    uri="https://api.openai.com"
    echo "URI not specified, using default: " $uri
  fi

  # Adding OpenAI key to shell profile
  # zsh profile
  if [ -f $HOME_USER/.zprofile ]; then
    echo "export OPENAI_API_KEY=$key" >>$HOME_USER/.zprofile
    echo "export OPENAI_API_URI=$uri" >>$HOME_USER/.zprofile
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
      echo 'export PATH=$PATH:/usr/local/bin' >>$HOME_USER/.zprofile
    fi
    echo "OpenAI key and chatgpt path added to $HOME_USER/.zprofile"
    source $HOME_USER/.zprofile
  # zshrc profile for debian
  elif [ -f $HOME_USER/.zshrc ]; then
    echo "export OPENAI_API_KEY=$key" >>$HOME_USER/.zshrc
    echo "export OPENAI_API_URI=$uri" >>$HOME_USER/.zshrc
    if [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
      echo 'export PATH=$PATH:/usr/local/bin' >>$HOME_USER/.zshrc
    fi
    echo "OpenAI key and chatgpt path added to $HOME_USER/.zshrc"
    source $HOME_USER/.zshrc
  # bash profile mac
  elif [ -f $HOME_USER/.bash_profile ]; then
    echo "export OPENAI_API_KEY=$key" >>$HOME_USER/.bash_profile
    echo "export OPENAI_API_URI=$uri" >>$HOME_USER/.bash_profile
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
      echo 'export PATH=$PATH:/usr/local/bin' >>$HOME_USER/.bash_profile
    fi
    echo "OpenAI key and chatgpt path added to $HOME_USER/.bash_profile"
    source $HOME_USER/.bash_profile
  # profile ubuntu
  elif [ -f $HOME_USER/.profile ]; then
    echo "export OPENAI_API_KEY=$key" >>$HOME_USER/.profile
    echo "export OPENAI_API_URI=$uri" >>$HOME_USER/.profile
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
      echo 'export PATH=$PATH:/usr/local/bin' >>$HOME_USER/.profile
    fi
    echo "OpenAI key and chatgpt path added to $HOME_USER/.profile"
    source $HOME_USER/.profile
  else
    export OPENAI_API_KEY=$key
    echo "You need to add this to your shell profile: export OPENAI_API_KEY=$key"
  fi
  echo "Installation complete"

else
  echo "Please take a look at the instructions to install manually: https://github.com/0xacx/chatGPT-shell-cli/tree/main#manual-installation "
  exit
fi
