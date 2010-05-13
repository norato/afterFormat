#!/bin/bash
#
# instalar.sh - Instala todos os softwares selecionados. O PC deve estar
#               conectado à internet. O tempo de instalação dependerá da
#               velocidade de sua conexão.
#
# ------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.0, 19-11-2009, Hugo Maia:
#       - Versão inicial.
#   v1.1, 08-05-2010, Hugo Maia Vieira:
#       - Retirados e adicionados itens, ajustando para o ubuntu 10.04
#   v1.2, 08-05-2010, Hugo Maia Vieira:
#       - Colocado o pacote de dicionarios no downloads do projeto e mudado o
#       script para baixar de lá se for necessário.
#
# ------------------------------------------------------------------------------
#
# Autor     : Hugo Henriques Maia Vieira <hugouenf@gmail.com>
#
# Licença: GPL.
#

# ==========================    Variáveis    ===================================

# Mandinga para pegar o diretório onde o script foi executado
FOLDER=$(cd $(dirname $0); pwd -P)

#================================ Menu =========================================

# Instala o dialog
echo "Espere um momento..."
sudo apt-get install -y dialog > /dev/null

opcoes=$( dialog --stdout --separate-output                                             \
    --title "afterFormat - Pós Formatação para Ubuntu 9.10 LST"                         \
    --checklist 'Selecione os softwares que deseja instalar:' 0 0 0                     \
    Desktop         "Muda \"Área de Trabalho\" para \"Desktop\" *(Apenas ptBR)"     ON  \
    Botões          "Muda os botões minimizar, maximizar e fechar para a direita"   ON  \
    Terminal        "Terminal com fundo preto e letras brancas"                     ON  \
    Ruby1.8         "Ambiente para desenvolvimento com Ruby1.8"                     ON  \
    Ruby1.9         "Ambiente para desenvolvimento com Ruby1.9"                     ON  \
    Rails           "Ambiente para desenvolvimento com Rails"                       ON  \
    MySql           "Banco de dados"                                                ON  \
    PostgreSQL      "Banco de dados"                                                OFF \
    Java            "Java Development Kit e Java Runtime Environment"               ON  \
    SVN             "Sistema de controle de versão"                                 ON  \
    Git             "Sistema de controle de versão com configurações básicas"       ON  \
    GitMeldDiff     "Torna o Meld o software para visualização do diff do git"      ON  \
    Python          "Ferramentas para desenvolvimento python"                       ON  \
    VIM             "Editor de texto, com configurações básicas"                    ON  \
    Gedit           "Plugins oficiais, Gmate e configurações básicas"               ON  \
    EnvyNG          "Software para instalação de drivers Nvidia e ATI"              OFF \
    StarDict        "Dicionário multi-línguas"                                      ON  \
    Xournal         "Software para fazer anotações e marcar texto em pdf"           ON  \
    AcrobatReader   "Software para fazer anotações e marcar texto em pdf"           ON  \
    Media           "Codecs, flashplayer e compactadores"                           ON  \
    Inkscape        "Software para desenho vetorial"                                ON  \
    RecordMyDesktop "Ferramenta para gravação do video e áudio do computador"       ON  \
    XChat           "Cliente IRC"                                                   ON  \
    Dia             "Editor de diagramas"                                           ON  \
    Chromium        "Versão opensouce do navegador web Google Chrome"               ON  \
    Firefox         "Complementos para o firefox"                                   ON  \
    Pidgin          "Cliente de mensagens instantâneas"                             ON  )
    Jdownloader     "Baixa automaticamente do rapidshare, megaupload e etc"         ON  )

#=============================== Processamento =================================

# Termina o programa se apertar cancelar
[ "$?" -eq 1 ] &&  exit 1

echo "$opcoes" |
while read opcao
do
    if [ "$opcao" = 'Desktop' ]
    then
        mv $HOME/Área\ de\ Trabalho $HOME/Desktop
        sed "s/"Área\ de\ Trabalho"/"Desktop"/g" $HOME/.config/user-dirs.dirs  > /tmp/user-dirs.dirs.modificado
        mv /tmp/user-dirs.dirs.modificado $HOME/.config/user-dirs.dirs
        xdg-user-dirs-gtk-update
        xdg-user-dirs-update
    fi

    if [ "$opcao" = 'Botões' ]
    then
        gconftool-2 --set "/apps/metacity/general/button_layout" --type string ":minimize,maximize,close"
    fi

    if [ "$opcao" = 'Terminal' ]
    then
        gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool "false"
    fi

    if [ "$opcao" = 'Ruby1.8' ]
    then
        sudo apt-get install -y ruby1.8 rubygems1.8 ruby1.8-dev libopenssl-ruby1.8 irb1.8
        sudo ./variaveis_ambiente.sh "ruby_on_rails1.8"
        echo "alias sudo='sudo env PATH=\$PATH'" >> ~/.bashrc
        ruby18=1
        #TODO: colcoar RVM
    fi

    if [ "$opcao" = 'Ruby1.9' ]
    then
        sudo apt-get install -y ruby1.9.1-full rubygems1.9.1 ruby1.9.1-dev libopenssl-ruby1.9.1 irb1.9
        sudo ./variaveis_ambiente.sh "ruby_on_rails1.9"
        test $ruby18 -ne 1 && echo "alias sudo='sudo env PATH=\$PATH'" >> ~/.bashrc
        ruby19=1
        #TODO: colcoar RVM
    fi

    if [ "$opcao" = 'Rails' ]
    then
        sudo apt-get install -y bcrypt libxml2 libxml2-dev libxslt1-dev
        sudo gem install rake
        sudo gem install rails
        sudo gem install haml
        sudo gem install formtastic
        sudo gem install inherited_resources
        sudo gem install database_cleaner
        sudo gem install bcrypt-ruby
        sudo gem install will_paginate
        sudo gem install factory_girl
        sudo gem install brazilian-rails
        sudo gem install cucumber-rails
        sudo gem install webrat
        sudo gem install rspec-rails
        sudo gem install mongrel
        sudo gem install capistrano
        sudo gem install authlogic
        sudo gem install remarkable_rails
        rails=1
    fi

    if [ "$opcao" = 'MySql' ]
    then
        sudo apt-get install -y mysql-server-5.0 libmysqlclient15-dev
        test $ruby18 -eq 1 && sudo apt-get install -y libmysql-ruby1.8
        test $ruby19 -eq 1 && sudo apt-get install -y libmysql-ruby1.9
        test $rails  -eq 1 && sudo gem install mysql
    fi

    if [ "$opcao" = 'PostgreSQL' ]
    then
        sudo apt-get install -y postgresql
        test $ruby18 -eq 1 && sudo apt-get install -y libpgsql-ruby1.8
        test $ruby19 -eq 1 && sudo apt-get install -y libpgsql-ruby1.9
        test $rails  -eq 1 && sudo gem install pg
    fi

    if [ "$opcao" = 'VIM' ]
    then
        sudo apt-get install -y vim
        sudo cp $FOLDER/vimrc.local /etc/vim/
    fi

    if [ "$opcao" = 'Gedit' ]
    then
        sudo ./repositorios.sh "gmate"
        sudo apt-get install -y gedit-plugins
        sudo apt-get install -y gedit-gmate
        # Preferências do gedit
        `gconftool-2 --set /apps/gedit-2/plugins/active-plugins -t list --list-type=str [docinfo,rails_extract_partial,rubyonrailsloader,spell,smart_indent,terminal,rails_hotkeys,indent,filebrowser,snippets,time,modelines,completion,trailsave,sort,align,colorpicker,smartspaces,sessionsaver,bracketcompletion,changecase,rails_hotcommands,codecomment]`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/auto_indent/auto_indent -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/bracket_matching/bracket_matching -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/colors/scheme -t str textmate`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/current_line/highlight_current_line -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/cursor_position/restore_cursor_position -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/line_numbers/display_line_numbers -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/right_margin/display_right_margin -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/right_margin/right_margin_position -t int 80`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/save/create_backup_copy -t bool false`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/tabs/insert_spaces -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/tabs/tabs_size -t int 4`
        `gconftool-2 --set /apps/gedit-2/preferences/editor/wrap_mode/wrap_mode -t str GTK_WRAP_NONE`
        `gconftool-2 --set /apps/gedit-2/preferences/ui/bottom_panel/bottom_panel_visible -t bool true`
        `gconftool-2 --set /apps/gedit-2/preferences/ui/side_pane/side_pane_visible -t bool true`
    fi

    if [ "$opcao" = 'Media' ]
    then
        sudo ./repositorios.sh "media"
        sudo apt-get install -y ubuntu-restricted-extras non-free-codecs libdvdcss2
        sudo apt-get install -y arj lha rar unace-nonfree unrar p7zip p7zip-full p7zip-rar

        uname -a | grep i686 1>& /dev/null # Ubuntu 32 bits
        if [ $? = 0 ]
            sudo apt-get install -y w32codecs
        uname -a | grep x86_64 1>& /dev/null # Ubuntu 64 bits
        if [ $? = 0 ]
            sudo apt-get install -y w64codecs
    fi

    if [ "$opcao" = 'Chromium' ]
    then
        sudo ./repositorios.sh "chromium"
        sudo apt-get install -y chromium-browser
    fi

    if [ "$opcao" = 'StarDict' ]
    then
        sudo apt-get install -y stardict
        wget -O /tmp/Dicionarios_StarDict.tar.gz http://github.com/downloads/hugomaiavieira/afterFormat/Dicionarios_StarDict.tar.gz
        sudo tar zxvf /tmp/Dicionarios_StarDict.tar.gz -C /usr/share/stardict/dic
    fi

    if [ "$opcao" = 'Firefox' ]
    then
        wget -O /tmp/firebug.xpi https://addons.mozilla.org/pt-BR/firefox/downloads/latest/1843/addon-1843-latest.xpi?src=addondetail
        firefox -install-global-extension /tmp/firebug.xpi
        wget -O /tmp/webDeveloper.xpi https://addons.mozilla.org/pt-BR/firefox/downloads/latest/60/addon-60-latest.xpi?src=addondetail
        firefox -install-global-extension /tmp/webDeveloper.xpi
        wget -O /tmp/downloadHelper.xpi https://addons.mozilla.org/pt-BR/firefox/downloads/latest/3006/addon-3006-latest.xpi?src=addondetail
        firefox -install-global-extension /tmp/downloadHelper.xpi
        wget -O /tmp/downThemAll.xpi https://addons.mozilla.org/en-US/firefox/downloads/latest/201/addon-201-latest.xpi?src=addondetail
        firefox -install-global-extension /tmp/downThemAll.xpi
    fi

    if [ "$opcao" = 'GitMeldDiff' ]
    then
        git --version 2> /dev/null
        if ! [ "$?" -eq 127 ]
        then
            sudo apt-get install -y meld
            touch $HOME/.config/git_meld_diff.py
            echo "#!/bin/bash" >> $HOME/.config/git_meld_diff.py
            echo "meld \"\$5\" \"\$2\"" >> $HOME/.config/git_meld_diff.py
            chmod +x $HOME/.config/git_meld_diff.py
            git config --global diff.external $HOME/.config/git_meld_diff.py
        else
            dialog --title 'Aviso' \
            --msgbox 'Para tornar o Meld o software para visualização do diff do git, o git deve estar instalado. Para insto, rode novamente o script marcando as opções Git e GitMeldDiff.' \
            0 0
        fi
    fi

    if [ "$opcao" = 'Python' ]
    then
        sudo apt-get install -y ipython python-dev

        wget -O /tmp/distribute_setup.py http://python-distribute.org/distribute_setup.py
        sudo python /tmp/distribute_setup.py

        sudo easy_install pip
        sudo pip install virtualenv

        sudo pip install virtualenvwrapper
        mkdir -p $HOME/Envs
        echo "export WORKON_HOME=\$HOME/Envs" >> $HOME/.bashrc
        echo "source /usr/local/bin/virtualenvwrapper.sh"  >> $HOME/.bashrc
        # TODO: Colocar no readme o que esta instalando e as configurações de variaveis ambiente
    if

    [ "$opcao" = 'Java' ]               && sudo apt-get install -y sun-java6-jdk sun-java6-jre
    [ "$opcao" = 'Git' ]                && sudo apt-get install -y git-core
    [ "$opcao" = 'SVN' ]                && sudo apt-get install -y subversion
    [ "$opcao" = 'EnvyNG' ]             && sudo apt-get install -y envyng-core envyng-gtk envyng-qt
    [ "$opcao" = 'Xournal' ]            && sudo apt-get install -y xournal
    [ "$opcao" = 'AcrobatReader' ]      && sudo apt-get install -y acroread
    [ "$opcao" = 'Inkscape' ]           && sudo apt-get install -y inkscape
    [ "$opcao" = 'RecordMyDesktop' ]    && sudo apt-get install -y gtk-recordmydesktop
    [ "$opcao" = 'XChat' ]              && sudo apt-get install -y xchat
    [ "$opcao" = 'Dia' ]                && sudo apt-get install -y dia
    [ "$opcao" = 'Pidgin' ]             && sudo apt-get install -y pidgin
    [ "$opcao" = 'Jdownloader' ]        && sudo ./repositorios.sh "jdownloader"; sudo apt-get install -y jdownloader
done

