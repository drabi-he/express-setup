read -p "Enter root folder name [backend]: " name
name=${name:-backend}
echo $name
cd $name
read -p "Which package manager would you like to use (npm/yarn/pnpm) [npm]: manager
