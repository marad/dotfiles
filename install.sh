
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing vim configuration..."
rm -rf $HOME/.vim
rm -rf $HOME/.vimrc
ln -s $DIR/vim $HOME/.vim
ln -s $DIR/vimrc $HOME/.vimrc

echo "Installing nvim configuration..."
rm -rf $HOME/.config/nvim/init.vim
rm -rf $HOME/.config/nvim/colors
ln -s $DIR/vimrc $HOME/.config/nvim/init.vim
ln -s $DIR/vim/colors $HOME/.config/nvim/colors

echo "Installing git configuration..."
rm -rf $HOME/.gitconfig
rm -rf $HOME/.gitignore_global
ln -s $DIR/gitconfig $HOME/.gitconfig
ln -s $DIR/gitignore_global $HOME/.gitignore_global

echo "Installing i3 configuration..."
rm -rf $HOME/.i3
ln -s $DIR/i3 $HOME/.i3

echo "Installing tmux configuration..."
rm -rf $HOME/.tmux.conf
ln -s $DIR/tmux.conf $HOME/.tmux.conf

echo "Installing .Xdefaults file..."
rm -rf $HOME/.Xdefaults
ln -s $DIR/Xdefaults $HOME/.Xdefaults

echo "Installind zsh configuration..."
rm -rf $HOME/.zshrc
ln -s $DIR/zshrc $HOME/.zshrc

echo "Installation finished!"
