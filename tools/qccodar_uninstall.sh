#!/bin/bash

condaversion="none"
if [ -d "/Users/codar/miniforge3" ]; then
  condaversion="miniforge3"
elif [ -d "/Users/codar/mambaforge3" ]; then 
  condaversion="mambaforge3"
elif [ -d "/Users/codar/miniconda3" ]; then 
  condaversion="miniconda3"  
fi

while true; do
read -p "Do you want to remove ${condaversion} (yes or no)? " choice

# Convert the input to lowercase for simplicity
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

if [[ "$choice" == "y" || "$choice" == "yes" ]]; then
    echo "Removing /Users/codar/${condaversion}"
    rm -rf /Users/codar/${condaversion}
    rm -rf /Users/codar/.conda
    rm -rf /Users/codar/.condarc
    rm -rf /Users/codar/.continuum

    # Detect the default shell (zsh or bash)
    SHELL_TYPE=$(basename "$SHELL")
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
       echo "After this program ends, you may want to remove any conda references in the /Users/codar/.zshrc file."
    elif [[ "$SHELL_TYPE" == "bash" ]]; then
       echo "After this program ends, you may want to remove any conda references in the /Users/codar/.bash_profile file."
    fi

    echo "Press any key to continue..."
    read -n 1 -s

    break

elif [[ "$choice" == "n" || "$choice" == "no" ]]; then
    echo "/Users/codar/${condaversion} will not be removed"
    break
else
    echo "Invalid response. Please enter yes or no."
fi
done


# Remove qccodar files
echo "Removing qccodar_files"
rm -rf /Users/codar/qccodar_files

# Remove Conda environment for qccodar
echo "Removing Conda environment for qccodar..."
conda remove --name qccodar --all

# Edit AnalysisOptions.txt to disable Radial Metric Output
ANALYSIS_OPTIONS_FILE="/Codar/SeaSonde/Configs/RadialConfigs/AnalysisOptions.txt"
if [ -f "$ANALYSIS_OPTIONS_FILE" ]; then
    echo "Editing line 21 of AnalysisOptions.txt to turn off Radial Metric Output..."
    sed -i '' '21s/.*/0           !21 Enable Radial Metric Output: 0(Off), 1(Enable), 2(Enable MaxVel.)/' "$ANALYSIS_OPTIONS_FILE"
else
    echo "Error: AnalysisOptions.txt not found at $ANALYSIS_OPTIONS_FILE"
fi

# Remove qccodar tasks in crontab 
echo "Removing qccodar tasks in crontab..."
crontab -l > /Users/codar/crontab_backup_copy.txt
CRON_FILE="/Users/codar/mycron.txt"
crontab -l > "$CRON_FILE" 2>/dev/null || touch "$CRON_FILE"
sed -i '' '/qccodar/d' "$CRON_FILE"
crontab "$CRON_FILE"
rm -f /Users/codar/mycron.txt
echo "*******************************************"
echo " "
echo "qccodar crontab entries removed."
echo "Remaining entries (if any) are listed below:"
crontab -l

echo " "
echo "*******************************************"
while true; do
read -p "Do you want to remove all of the backup files located in /Users/codar/qccodar_backup (yes or no)? " choice2

# Convert the input to lowercase for simplicity
choice2=$(echo "$choice2" | tr '[:upper:]' '[:lower:]')

if [[ "$choice2" == "y" || "$choice2" == "yes" ]]; then
    echo "Removing /Users/codar/qccodar_backup"
    rm -rf /Users/codar/qccodar_backup
    break
elif [[ "$choice2" == "n" || "$choice2" == "no" ]]; then
    break
else
    echo "Invalid response. Please enter yes or no."
fi
done


# Final messages
echo " "
echo "*******************************************"
echo "qccodar has been successfully uninstalled!" 
echo "Archivalist for Radial Metric tasks have not been altered."
echo "*******************************************"
echo " "
echo "NOTE:"
echo "As a precaution, a backup of crontab contents was saved to /Users/codar/crontab_backup_copy.txt. You can delete this file if your crontab entries are listed correctly above."
echo " "


