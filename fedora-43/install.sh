#!/bin/bash
REL="$(rpm -E %fedora)"
VER="1a"
echo "thanks to sanjayankur31 for the script base"
echo "version $VER"

setup_repos() {
    sudo dnf install dnf5-plugins
    # taskjuggler
    sudo dnf copr enable ankursinha/rubygem-taskjuggler
    # NeuroFedora
    sudo dnf copr enable @neurofedora/neurofedora-extra

    # RPMFusion
    sudo dnf install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$REL".noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$REL".noarch.rpm \

    sudo dnf update --refresh
}

update_groups() {
    sudo dnf group upgrade --with-optional Multimedia

    # Music and multimedia
    # https://docs.fedoraproject.org/en-US/quick-docs/assembly_installing-plugins-for-playing-movies-and-music/
    # https://rpmfusion.org/Configuration
    sudo dnf groupupdate multimedia
    sudo dnf groupupdate sound-and-video

    # Fusion appstream data
    sudo dnf groupupdate core

    # https://rpmfusion.org/CommonBugs?highlight=%28ffmpeg%29
    # swap
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing
}

install_basic() {
    # Basics
    sudo dnf install sway kitty krusader glances mako
    --setopt=strict=0
    # parcellite
}
install_necessities() {
    # Basics
    sudo dnf install \
        keepassxc btop kate ark \
        kactivitymanagerd ad \

    --setopt=strict=0
    # parcellite
}


install_flatpaks() {
    # Flatpaks
    echo "Installing flatpaks from Flathub"
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    #flatpak --user install flathub com.skype.Client
    #flatpak --user install flathub com.uploadedlobster.peek
    #flatpak --user install flathub com.jgraph.drawio.desktop

    flatpak --user install flathub com.github.tchx84.Flatseal
    flatpak --user install flathub com.usebottles.bottles
    flatpak --user install flathub io.github.alainm23.planify
    flatpak --user install flathub io.github.tobagin.karere
    flatpak --user install flathub org.vinegarhq.Sober
    flatpak --user install flathub org.vinegarhq.Vinegar
    flatpak --user install flathub md.obsidian.Obsidian
    flatpak --user install flathub net.pcsx2.PCSX2
    flatpak --user install flathub re.sonny.Playhouse
    flatpak --user install flathub im.riot.Riot
    #flatpak --user install flathub us.zoom.Zoom
}

enable_services () {
    echo "Starting/enabling syncthing"
    systemctl --user start syncthing.service
    systemctl --user enable syncthing.service

    echo "Starting/enabling psi-notify"
    systemctl --user start psi-notify.service
    systemctl --user enable psi-notify.service

    # https://askubuntu.com/questions/340809/how-can-i-adjust-the-default-passphrase-caching-duration-for-gpg-pgp-ssh-keys/358514#358514
    echo "Configuring gnome-keyring to forget gpg passphrases after 7200 seconds"
    gsettings set org.gnome.crypto.cache gpg-cache-method "idle"
    gsettings set org.gnome.crypto.cache gpg-cache-ttl "7200"
}


usage() {
    echo "$0: Install packages and software"
    echo
    echo "Usage: $0 [-subtfanFh]"
    echo
    echo "-s: set up DNF repos"
    echo "-u: update groups: implies -s"
    echo "-b: install basics: implies -s"
    echo "-t: install necessities: implies -s"
    echo "-n: install other programs: implies -s"
    echo "-f: install flatpaks from flathub: also sets up flathub"
    echo "-a: do all of the above"
    echo "-h: print this usage text and exit"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

# parse options
while getopts "usbtfahnF" OPTION
do
    case $OPTION in
        s)
            setup_repos
            exit 0
            ;;
        u)
            setup_repos
            update_groups
            enable_services
            exit 0
            ;;
        b)
            setup_repos
            install_basics
            enable_services
            exit 0
            ;;
        t)
            setup_repos
            install_necessities
            exit 0
            ;;
        f)
            install_flatpaks
            exit 0
            ;;
        n)
            setup_repos
            install_nvidia
            exit 0
            ;;
        a)
            setup_repos
            update_groups
            install_basics
            install_texlive_packages
            install_flatpaks
            enable_services
            exit 0
            ;;
        e)
            enable_services
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
