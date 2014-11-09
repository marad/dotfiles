
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo $DIR

rm -rf $HOME/.vim
rm -rf $HOME/.vimrc
rm -rf $HOME/.gitconfig


ln -s $DIR/.vim $HOME/.vim
ln -s $DIR/.vimrc $HOME/.vimrc
ln -s $DIR/.gitconfig $HOME/.gitconfig
