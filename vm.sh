#!/bin/bash
# based on a script made by https://github.com/shaolin-peanut for his OCAML Piscine
# and one by https://github.com/t-h2o for his Inception

RED="\033[0;31m"
GREEN="\033[0;32m"
RESET="\033[0m"
YELLOW="\033[0;33m"
DL_DIR="/goinfre/$(whoami)" # folder to use to download/extract ! goinfre is only on the mac at school !
RAM_SIZE="4096"

# Variables to fill, includes the URL to download the iso from, some folder name ...
URL_DOWNLOAD="https://sourceforge.net/projects/osboxes/files/v/vb/55-U-u/25.04/64bit.7z/download"
DISTRO_NAME="ubuntu" # name of the distro, used for later destinations folder
COMPUTER_ARCHITECTURE="64bit" # most likely 64bit, corresponds to the name of the archive
ARCHIVE_NAME="${DL_DIR}/${DISTRO_NAME}.7z" # destination folder of the download
EXTRACTED_DIR="${DL_DIR}/${DISTRO_NAME}/${COMPUTER_ARCHITECTURE}" # destination folder of the extracted archive
VDI_NAME="${DL_DIR}/${COMPUTER_ARCHITECTURE}/Ubuntu Server 25.04 (64bit).vdi" # path + file name of the VDI in the extracted folder
OS_TYPE="Ubuntu_64" # use 'VBoxManage list ostypes' to list the available OS types, use the ID field of the wanted OS
VM_NAME="ubuntu-ocaml"
SHARED_FOLDER_GUEST="/media/sf" # the shared folder will be mounted in the VM at /media/sf_<shared_folder_name>


list_existing_vms() {
    existing_vm_list=$(VBoxManage list vms)
    if [ -z "${existing_vm_list}" ]; then
        echo -e "${RED}No existing VMs${RESET}\n"
        main
    else
        echo "List of existing VMs:"
        echo "${existing_vm_list}"
    fi
}


download_vdi() {
    echo "Downloading the VDI from ${URL_DOWNLOAD} ..."
    if [ ! -f "${VDI_NAME}" ]; then
        echo "VDI file not found. Checking archive..."

        if [ ! -f "${ARCHIVE_NAME}" ]; then
            echo -e "${GREEN}Starting download of the VDI from ${URL_DOWNLOAD} ...${RESET}"
            curl -L -o "${ARCHIVE_NAME}" "${URL_DOWNLOAD}"
        else
            echo -e "${YELLOW}Archive already downloaded: ${ARCHIVE_NAME}${RESET}\n"
        fi

        while [ ! -f "${VDI_NAME}" ]; do
            echo "VDI file not found."
            echo "Make sure ${VDI_NAME} match with the content extracted in ${EXTRACTED_DIR}"
            echo -e "${YELLOW}Open ${DL_DIR}?${RESET}"
            read -p "Choice (y/N): " yn
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                open "${DL_DIR}"
            else
                echo "Make sure you extract the archive at ${DL_DIR} and the VDI file name matches with the variable VDI_NAME"
            fi
            read -p "Press Enter after extracting the archive file..."
        done
        echo -e "${GREEN}The virtual disk image is ready at ${VDI_NAME}${RESET}\n"
    else
        echo -e "${GREEN}VDI file already exists: ${VDI_NAME}${RESET}\n"
    fi
}

create_vm() {
    read -p "Enter the name of the VM to create [default: ${VM_NAME}]: " input_name
    input_name=${input_name:-$VM_NAME}

    if VBoxManage list vms | grep -q "\"${input_name}\""; then
        echo -e "${RED}VM '${input_name}' already exists. Returning to menu.${RESET}"
        main
    fi

    echo -e "${YELLOW}Creating VirtualBox VM '${input_name}'...${RESET}"

    VBoxManage createvm --name "${input_name}" --ostype "${OS_TYPE}" --register
    VBoxManage modifyvm "${input_name}" --memory "${RAM_SIZE}" --cpus 2 --nic1 nat
    VBoxManage modifyvm "${input_name}" --natpf1 "Rule 1,tcp,127.0.0.1,2222,,22"
    VBoxManage storagectl "${input_name}" --name "SATA Controller" --add sata --controller IntelAHCI
    VBoxManage storageattach "${input_name}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VDI_NAME}"
    VBoxManage modifyvm "${input_name}" --audio-driver none
    VBoxManage modifyvm "${input_name}" --vram 32
    VBoxManage modifyvm "${input_name}" --clipboard-mode=bidirectional
    VBoxManage modifyvm "${input_name}" --graphicscontroller=vmsvga
    echo -e "${GREEN}VirtualBox VM '${input_name}' successfully created${RESET}"
}

add_shared_folder() {
    list_existing_vms

    read -p "Which VM to add a shared folder to [default: ${VM_NAME}]: " target_vm
    target_vm=${target_vm:-$VM_NAME}

    if ! echo "${existing_vm_list}" | grep -q "\"${target_vm}\""; then
        echo -e "${RED}${target_vm} is not an existing VM. Please provide a valid VM name.${RESET}"
        add_shared_folder
    fi

    echo -e "${GREEN}Adding shared folder to '${target_vm}'...${RESET}"

    PWD=$(pwd)
    while true; do
        read -p "Enter path to use as shared folder [default: ${PWD}]: " SHARED_FOLDER
        SHARED_FOLDER=${SHARED_FOLDER:-$PWD}

        while [ ! -d "${SHARED_FOLDER}" ]; do
            echo -e "${RED}Folder does not exist. Please provide a valid shared folder path.${RESET}"
            read -p "Enter path to use as shared folder (default: ${PWD}): " SHARED_FOLDER
            SHARED_FOLDER=${SHARED_FOLDER:-$PWD}
        done

        FOLDER_NAME=$(basename "${SHARED_FOLDER}")

        # Sanitize the name
        SAFE_NAME=$(echo "${FOLDER_NAME}" | sed 's/[^a-zA-Z0-9_-]/_/g')

        echo -e "${GREEN}Adding shared folder '${SAFE_NAME}' -> '${SHARED_FOLDER}' to VM '${target_vm}'.${RESET}"

        VBoxManage sharedfolder add "${target_vm}" --name "${SAFE_NAME}" --hostpath "${SHARED_FOLDER}" --automount --auto-mount-point="${SHARED_FOLDER_GUEST}"
        VBoxManage setextradata "${target_vm}" "VBoxInternal2/SharedFoldersEnableSymlinksCreate/${SHARED_FOLDER}" 1
        echo -e "${GREEN}Shared folder added successfully.${RESET}"

        read -p "Add another shared folder to '${target_vm}'? (y/N): " more
        more=${more:-N}
        if [[ "${more}" != "y" && "${more}" != "Y" ]]; then
            break
        fi
    done
}

start_vm() {
    list_existing_vms

    read -p "Which VM to start [default: ${VM_NAME}]: " target_vm
    target_vm=${target_vm:-$VM_NAME}

    if ! echo "${existing_vm_list}" | grep -q "\"${target_vm}\""; then
        echo -e "${RED}${target_vm} is not an existing VM. Please provide a valid VM name.${RESET}"
        start_vm
    fi

    read -p "Start VM '${target_vm}' headless? (y/N): " headless_choice
    headless_choice=${headless_choice:-N}

    if [[ "${headless_choice}" == "y" || "${headless_choice}" == "Y" ]]; then
        echo -e "${YELLOW}Starting VM '${target_vm}' headless...${RESET}"
        VBoxManage startvm "${target_vm}" --type headless
    else
        echo -e "${YELLOW}Starting VM '${target_vm}' with GUI...${RESET}"
        VBoxManage startvm "${target_vm}"
    fi

    echo -e "${GREEN}VM ${target_vm} started${RESET}"
    echo "If a shared folder has been added it will be mounted at /media/sf_<shared_folder_name> in the VM"
    echo -e "If the ISO comes from osboxes: ${GREEN}user => osboxes | password => osboxes.org (same for root)${RESET}"
}

poweroff_vm() {
    running_vm=$(VBoxManage list runningvms)
    if [ -z "${running_vm}" ]; then
        echo -e "${RED}No running VMs to power off${RESET}\n"
        main
    fi

    echo "List of running VMs:"
    echo "${running_vm}"

    read -p "Which VM to power off [default: ${VM_NAME}]: " target_vm
    target_vm=${target_vm:-$VM_NAME}

    if ! echo "${running_vm}" | grep -q "${target_vm}"; then
        echo -e "${RED}${target_vm} is not a running VM. Please provide a valid running VM name.${RESET}"
        poweroff_vm
    fi

    echo "Powering off VM '${target_vm}'..."
    VBoxManage controlvm "${target_vm}" poweroff
    echo -e "${GREEN}VM '${target_vm}' powered off.${RESET}\n"
}

delete_vm() {
    list_existing_vms

    read -p "Which VM to delete [default: ${VM_NAME}]: " target_vm
    target_vm=${target_vm:-$VM_NAME}

    if ! echo "$existing_vm_list" | grep -q "${target_vm}"; then
        echo -e "${RED}${target_vm} does not exist. Please provide a valid VM name.${RESET}"
        delete_vm
    fi

    echo "Unregistering and deleting VM '${target_vm}'..."

    # https://www.virtualbox.org/manual/ch08.html#vboxmanage-unregistervm
    # --delete -> automatically deletes some files related to the VM present in /home/${whoami}/VirtualBox VMs/${target_vm} and the VDI file
    VBoxManage unregistervm "${target_vm}" #--delete
    rm -rf "/home/$(whoami)/VirtualBox VMs/${target_vm}"

    echo -e "${GREEN}VM '${target_vm}' deleted.${RESET}"

    echo "Use the 'Delete extracted archive folder' option to fully delete the '${DL_DIR}/${DISTRO_NAME}/' folder ..."
}

delete_extracted_archive_folder() {
    echo -e "${YELLOW}Delete the extracted archive folder '${DL_DIR}/${DISTRO_NAME}/'${RESET} ?"
    read -p "Confirm (y/N): " confirmation
    if [[ "${confirmation}" == "y" || "${confirmation}" == "Y" ]]; then
        rm -rf "${DL_DIR}/${DISTRO_NAME}/"
        echo -e "${GREEN}Extracted archive folder deleted.${RESET}\n"
    else
        echo -e "${YELLOW}Extracted archive folder not deleted.${RESET}\n"
    fi
}

menu() {
    echo "VirtualBox VM Manager Script:"
    echo "[1] Download VDI"
    echo "[2] Create VM"
    echo "[3] Add shared folder"
    echo "[4] Start VM"
    echo "[5] PowerOff VM"
    echo "[6] Delete VM"
    echo "[7] Delete extracted archive folder"
    echo "[8] Exit"
    read -p "Choose an option [1-8]: " choice

    if [[ $choice -ge 1 && $choice -le 8 ]]; then
        return $choice
    else
        echo -e "\n${RED}Invalid choice. Try again${RESET}\n"
        menu
    fi
}

main() {
    if [ -z "${URL_DOWNLOAD}" ] || [ -z "${ARCHIVE_NAME}" ] || [ -z "${EXTRACTED_DIR}" ] || \
    [ -z "${VDI_NAME}" ] || [ -z "${OS_TYPE}" ] || [ -z "${VM_NAME}" ]; then
        echo -e "${RED}One or more required variables are empty.${RESET}"
        echo "The variables to check are URL_DOWNLOAD, ARCHIVE_NAME, EXTRACTED_DIR, VDI_NAME, OS_TYPE and VM_NAME."
        exit 1
    else
        echo "--------------------"
        echo -e "${GREEN}All variables are set correctly.${RESET}"
        echo "--------------------"
    fi

    menu

    answer=$?
    if [ "${answer}" -eq 1 ]; then
        download_vdi
    elif [ "${answer}" -eq 2 ]; then
        create_vm
    elif [ "${answer}" -eq 3 ]; then
        add_shared_folder
    elif [ "${answer}" -eq 4 ]; then
        start_vm
    elif [ "${answer}" -eq 5 ]; then
        poweroff_vm
    elif [ "${answer}" -eq 6 ]; then
        delete_vm
    elif [ "${answer}" -eq 7 ]; then
        delete_extracted_archive_folder
    elif [ "${answer}" -eq 8 ]; then
        exit 1
    fi

    main
}

main
