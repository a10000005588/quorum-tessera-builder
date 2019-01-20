
echo "Please select an option: "
echo "(1) Create Quorum Network "
echo "(2) Join Existing Network "
echo "(3) Exist "
read -p "option:" option

if [ "$option" = "1" ]; then 
    ./lib/setup.sh
elif [ "$option" = "2" ]; then
    ./lib/join_network.sh
else
    exit
fi
