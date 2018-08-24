# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$HOME/go/bin:$PATH";

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra,bash_completion/*}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
