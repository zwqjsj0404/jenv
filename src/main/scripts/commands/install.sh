#!/bin/bash
#
#   Copyright 2012 Jacky Chan
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Global variables
JENV_SERVICE="@JENV_SERVICE@"
JENV_VERSION="@JENV_VERSION@"
JENV_DIR="$HOME/.jenv"

# Local variables
jenv_tmp_folder="${JENV_DIR}/tmp"
jenv_zip_file="${jenv_tmp_folder}/jenv-${JENV_VERSION}.zip"
jenv_ext_folder="${JENV_DIR}/ext"
jenv_bash_profile="${HOME}/.bash_profile"
jenv_profile="${HOME}/.profile"
jenv_bashrc="${HOME}/.bashrc"
jenv_zshrc="${HOME}/.zshrc"
jenv_platform=$(uname)

jenv_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR JENV TO WORK!!!
[[ -s "$HOME/.jenv/bin/jenv-init.sh" ]] && source "$HOME/.jenv/bin/jenv-init.sh"
EOF
)

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
case "`uname`" in
    CYGWIN*)
        cygwin=true
        ;;
        
    Darwin*)
        darwin=true
        ;;
esac


echo '                                                                     '
echo 'Thanks for using                                                     '
echo '                                                                     '
echo '        ___   _______  _____  ___  ___      ___                      '
echo '       |"  | /"     "|(\"   \|"  \|"  \    /"  |                     '
echo '       ||  |(: ______)|.\\   \    |\   \  //  /                      '
echo '       |:  | \/    |  |: \.   \\  | \\  \/. ./                       '
echo '    ___|  /  // ___)_ |.  \    \. |  \.    //                        '
echo '   /  :|_/ )(:      "||    \    \ |   \\   /                         '
echo '  (_______/  \_______) \___|\____\)    \__/                          '
echo '                                                                     '
echo '                                       Will now attempt installing...'
echo '                                                                     '


# Sanity checks

echo "Looking for a previous installation of JENV..."
if [ -d "${JENV_DIR}" ]; then
	echo "JENV found."
	echo ""
	echo "======================================================================================================"
	echo " You already have JENV installed."
	echo " JENV was found at:"
	echo ""
	echo "    ${JENV_DIR}"
	echo ""
	echo " Please consider running the following if you need to upgrade."
	echo ""
	echo "    $ jenv selfupdate"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for unzip..."
if [ -z $(which unzip) ]; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install unzip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing unzip."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for curl..."
if [ -z $(which curl) ]; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " JENV uses curl for crucial interactions with it's backend server."
	echo ""
	echo " Restart after installing curl."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Installing jenv scripts..."

mkdir -p "${jenv_tmp_folder}"
echo "Download script archive..."
curl -s "${JENV_SERVICE}/jenv-${JENV_VERSION}.zip?platform=${jenv_platform}&purpose=install" > "${jenv_zip_file}"

echo "Extract script archive..."
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${jenv_zip_file}") -d "${JENV_DIR}"
else
	unzip -qo "${jenv_zip_file}" -d "${JENV_DIR}"
fi

echo "Attempt update of bash profiles..."
if [ ! -f "${jenv_bash_profile}" -a ! -f "${jenv_profile}" ]; then
	echo "#!/bin/bash" > "${jenv_bash_profile}"
	echo "${jenv_init_snippet}" >> "${jenv_bash_profile}"
	echo "Created and initialised ${jenv_bash_profile}"
else
	if [ -f "${jenv_bash_profile}" ]; then
		if [[ -z `grep 'jenv-init.sh' "${jenv_bash_profile}"` ]]; then
			echo -e "\n${jenv_init_snippet}" >> "${jenv_bash_profile}"
			echo "Updated existing ${jenv_bash_profile}"
		fi
	fi

	if [ -f "${jenv_profile}" ]; then
		if [[ -z `grep 'jenv-init.sh' "${jenv_profile}"` ]]; then
			echo -e "\n${jenv_init_snippet}" >> "${jenv_profile}"
			echo "Updated existing ${jenv_profile}"
		fi
	fi
fi

if [ ! -f "${jenv_bashrc}" ]; then
	echo "#!/bin/bash" > "${jenv_bashrc}"
	echo "${jenv_init_snippet}" >> "${jenv_bashrc}"
	echo "Created and initialised ${jenv_bashrc}"
else
	if [[ -z `grep 'jenv-init.sh' "${jenv_bashrc}"` ]]; then
		echo -e "\n${jenv_init_snippet}" >> "${jenv_bashrc}"
		echo "Updated existing ${jenv_bashrc}"
	fi
fi

echo "Attempt update of zsh profiles..."
if [ ! -f "${jenv_zshrc}" ]; then
	echo "${jenv_init_snippet}" >> "${jenv_zshrc}"
	echo "Created and initialised ${jenv_zshrc}"
else
	if [[ -z `grep 'jenv-init.sh' "${jenv_zshrc}"` ]]; then
		echo -e "\n${jenv_init_snippet}" >> "${jenv_zshrc}"
		echo "Updated existing ${jenv_zshrc}"
	fi
fi

echo -e "\n\n\nAll done!\n\n"

echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${JENV_DIR}/bin/jenv-init.sh\""
echo ""
echo "Then issue the following command:"
echo ""
echo "    jenv help"
echo ""
echo "Enjoy!!!"
