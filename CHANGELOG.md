# Changelog

## [1.1.0](https://github.com/jmarcelomb/.dotfiles/compare/v1.0.0...v1.1.0) (2025-04-08)


### Features

* add Nix-Darwin configuration and restructure home packages ([e5ecfd6](https://github.com/jmarcelomb/.dotfiles/commit/e5ecfd6d33b0a90a167f17c835ec75b308d7c8b1))
* adds chakra host, which is my home server ([7a7edb5](https://github.com/jmarcelomb/.dotfiles/commit/7a7edb5218b41691d8fa35eb95fb5c9a26f5bd6e))
* adds first chakra server nix config ([034cdb8](https://github.com/jmarcelomb/.dotfiles/commit/034cdb8f55aae054c7e073fb30b58f298e8f9110))
* adds nix-darwin bins to path & updates kitty font name ([93d1451](https://github.com/jmarcelomb/.dotfiles/commit/93d14510fb9fd10d5f1c5423c9a5ef5d75a5286e))
* **git:** enhance git configuration with additional settings ([e7913e5](https://github.com/jmarcelomb/.dotfiles/commit/e7913e511a26d03f7defc4b534bd59e39f82014a))
* **nix-darwin:** add new workspace and app configurations ([79163df](https://github.com/jmarcelomb/.dotfiles/commit/79163dffc96fa247621d22084d63ef58777a64e5))
* **nix-darwin:** adds system, homebrewe and home manager, common-home-packages.nix ([1f93852](https://github.com/jmarcelomb/.dotfiles/commit/1f938520f98a603b39934ab957a29baf4efab1d1))
* **nix:** adds home manager to flake & hardcoded system ([ad04b73](https://github.com/jmarcelomb/.dotfiles/commit/ad04b733ab26e0435882119bb7cdbbe3b1b0989b))
* **nix:** adds home manager to flake & hardcoded system ([8f485ab](https://github.com/jmarcelomb/.dotfiles/commit/8f485ab0f31e9e9bcfe8084ba289715f070c712b))
* **sketchybar:** updates icons to use lf symbols ([ad18f4b](https://github.com/jmarcelomb/.dotfiles/commit/ad18f4bc4824e66ceadcdf4dc90b9ba088947388))
* update aerospace.nix and flake.nix configurations ([3137b27](https://github.com/jmarcelomb/.dotfiles/commit/3137b2738d78a8d2f584c8b63fb5132ddfacad4f))
* update git config to prune tags and fetch all ([360ac33](https://github.com/jmarcelomb/.dotfiles/commit/360ac337057eed3bde30539877dbdc6ed8472916))
* update workspace rules and add new Homebrew package ([b94885f](https://github.com/jmarcelomb/.dotfiles/commit/b94885f9c76ca1b730e7eb1fcca479eaa8910bc5))
* **yazi:** add keymap to navigate to the root of Git repository ([51ee9a6](https://github.com/jmarcelomb/.dotfiles/commit/51ee9a604e31a328acbfcd301495fa642fb8faf9))
* **yazi:** add keymap to open nvim in current working directory ([01942ce](https://github.com/jmarcelomb/.dotfiles/commit/01942ceb9f6998ed86e120525cd87c3f5fd06c22))
* **yazi:** adds fr plugin enabling dynamic search using rg or fzf ([38e757c](https://github.com/jmarcelomb/.dotfiles/commit/38e757c90986fd95554fe44fe836b171485968fe))
* **yazi:** adds gu and gd to go up and down in parent directory ([24779f9](https://github.com/jmarcelomb/.dotfiles/commit/24779f9dc648cc2defbaee789a872151abe6eb59))
* **yazi:** adds keymap for confirm-quit ([b166095](https://github.com/jmarcelomb/.dotfiles/commit/b166095fe6f4e08fbb4443d554ccc1b8fcf68208))
* **yazi:** adds shift up and shift down to move preview ([6aebbfe](https://github.com/jmarcelomb/.dotfiles/commit/6aebbfe2fa3c669c433bcda8e7dc3feb25fb653d))
* **yazi:** adds smart tab plugin ([5ac0f5c](https://github.com/jmarcelomb/.dotfiles/commit/5ac0f5cbf4ea504e33ea257758b36567e5d88087))
* **yazi:** adds toggle-plane plugin allowing maximing & toggle preview ([a1deca2](https://github.com/jmarcelomb/.dotfiles/commit/a1deca27e64ed5f841772c9e95b4b040b2c3c3ee))
* **yazi:** confirm quit when multiple tabs are enabled ([082e685](https://github.com/jmarcelomb/.dotfiles/commit/082e685b5304b8779f384ad8330e15246293885d))
* **zellij:** uncomment default_shell to set fish as the default shell ([e5b42f4](https://github.com/jmarcelomb/.dotfiles/commit/e5b42f4a369362dfe935c5a144d069db84c10429))


### Bug Fixes

* adds cron and needed changes for server ([5eb3f53](https://github.com/jmarcelomb/.dotfiles/commit/5eb3f53c8231436b9e7917057afdc748c3aaaedc))
* adds mkdir -p ~/.config to setup.sh file ([e1d41af](https://github.com/jmarcelomb/.dotfiles/commit/e1d41afe881b79a8d32a42ce92eea5550fd945a6))
* automatic current system ([f1700e3](https://github.com/jmarcelomb/.dotfiles/commit/f1700e38c469781d7fb8e1dc0235606414ff1af6))
* bash.marcelo file type and removes cargo verbosity when not installed ([34af2cb](https://github.com/jmarcelomb/.dotfiles/commit/34af2cb1c30320555036a561a7bc288202ea38ac))
* enable default layout and pane frames in zellij config ([002a46e](https://github.com/jmarcelomb/.dotfiles/commit/002a46eb90895aed094ae98df0b410cecba7582c))
* returns if .bashrc.marcelob is called in non-iteractive mode ([2548864](https://github.com/jmarcelomb/.dotfiles/commit/2548864e4bec691765d37e36614da7eb3a7aaff4))
* update paths for sketchybar and aerospace commands ([1e40a0f](https://github.com/jmarcelomb/.dotfiles/commit/1e40a0f5a2a10e80f21e1292e01e2a6a844e3aa0))

## 1.0.0 (2025-03-03)


### Features

* add alias for git commit with edit and message options ([4bec3cc](https://github.com/jmarcelomb/.dotfiles/commit/4bec3cc8501d68df21ae6e181d0046dfbd96530e))
* add configuration for yazi ([94804c9](https://github.com/jmarcelomb/.dotfiles/commit/94804c92f38509dfb464541c98e98b2add93fe3b))
* add direnv configuration for virtual environment management ([3547d39](https://github.com/jmarcelomb/.dotfiles/commit/3547d39d9ae318cb42edc9f3b2298dd501495f28))
* add git, eza-preview, chmod, and starship plugins to yazi configuration ([32fa96d](https://github.com/jmarcelomb/.dotfiles/commit/32fa96d906dcd276b2b604bb93de9ca526cdc870))
* add kitty configuration and update install.conf.yaml ([bcf7020](https://github.com/jmarcelomb/.dotfiles/commit/bcf7020ae7f427bdc14678a33a66b7e9fa78093a))
* add lazygit plugin for Yazi ([126b493](https://github.com/jmarcelomb/.dotfiles/commit/126b49359cabf856f9f5cd9231faf09b39996bc0))
* add osc52 script for clipboard integration via ANSI escape ([53630d0](https://github.com/jmarcelomb/.dotfiles/commit/53630d0aeed87ef2bcb445ad10e68602b3f059e8))
* add script aliases for copy and paste commands ([6c2cb4b](https://github.com/jmarcelomb/.dotfiles/commit/6c2cb4b564ca6afa7867a7f3c2dfdbae8994403c))
* Add shell completions for `uv` tool ([a88db7a](https://github.com/jmarcelomb/.dotfiles/commit/a88db7ad6d2a86bab39d3a672598200ae26fcb62))
* add starship duck when using yazi subshell ([30ceb78](https://github.com/jmarcelomb/.dotfiles/commit/30ceb7852c42c93ce5ac6c8724ca2168031982e7))
* added model argument to the script for customizable use ([3d23e10](https://github.com/jmarcelomb/.dotfiles/commit/3d23e1051435096aaf8b2e27309100154e4d0fd6))
* added new scripts for generating commit messages and running models ([12dbc8d](https://github.com/jmarcelomb/.dotfiles/commit/12dbc8d2fb0d409b3219ea00fa20616ba54b7ef9))
* added shortcuts for common Git commands in fish aliases ([6319653](https://github.com/jmarcelomb/.dotfiles/commit/631965367685ee4e776ac663fc6772d1984641c3))
* **alacritty:** Add toggle vi mode bindings ([55beb21](https://github.com/jmarcelomb/.dotfiles/commit/55beb216904097705fab2e54bb1228f757e619d3))
* enable macOS option as alt key in kitty config ([046e67e](https://github.com/jmarcelomb/.dotfiles/commit/046e67ed5e7802a2542bb7bac7b41c90cf3d40a1))
* Enhance commit message generation script ([e6cb3d9](https://github.com/jmarcelomb/.dotfiles/commit/e6cb3d99bb747ccfa30f715215ee50207c0ee817))
* enhance input handling script with color support and help option ([c7860be](https://github.com/jmarcelomb/.dotfiles/commit/c7860bec385a6a6ad880c65c7b31d5d6561271cf))
* **fish:** add help function for enhanced command assistance ([0c9a8a1](https://github.com/jmarcelomb/.dotfiles/commit/0c9a8a1268ffc9e9582291331e2077d537c6bf9b))
* **git:** re-adds gpgsign setting to git, and reorders ([5a0a72f](https://github.com/jmarcelomb/.dotfiles/commit/5a0a72fadd649df596b36d8fd85d5ab56c1330ba))
* improve input script with color feedback and help functionality ([f215041](https://github.com/jmarcelomb/.dotfiles/commit/f215041236844c0d3fcfd17270a70c2ae087c6e3))
* rename osc52 script to copy and add paste helper script ([c96904a](https://github.com/jmarcelomb/.dotfiles/commit/c96904a0909955787d7cce7b82ca804c781ffdfe))
* **scripts:** add lpaste script and enhance paste script functionality ([e79fc6b](https://github.com/jmarcelomb/.dotfiles/commit/e79fc6b961ac772f6c9796a7b7da1b1d0ae30d87))
* **scripts:** enhance context handling and add generation attempts option ([9e2e94a](https://github.com/jmarcelomb/.dotfiles/commit/9e2e94a90051afe347441ad9cbd54394c043b963))
* update neovim submodule to latest version ([9c47b27](https://github.com/jmarcelomb/.dotfiles/commit/9c47b27b8b69d7a9e3aa8640322c0023d19e782a))


### Bug Fixes

* adjust symbol spacing and format in starship configuration ([b8f4de6](https://github.com/jmarcelomb/.dotfiles/commit/b8f4de6b34d77a4803ec7a0fcd26e9aef40c0658))
* change exit code to 0 when no input is detected in paste script ([604abfb](https://github.com/jmarcelomb/.dotfiles/commit/604abfbe6eaa55c33fe5a6b0732ef898fcaaaad8))
* change log level from ERROR to INFO in gen_commit_msg ([5877621](https://github.com/jmarcelomb/.dotfiles/commit/58776217fe6d93d5e3b3c6d46a9a7e530293f1f0))
* fzf no permissions ([53ae8b6](https://github.com/jmarcelomb/.dotfiles/commit/53ae8b6eb7e59d3ff4976d99dedafb0fd61de90c))
* pre-commit trailing space ([523bd25](https://github.com/jmarcelomb/.dotfiles/commit/523bd25dd02d836f1402d55dad058b750d4a1159))
* replace non-portable escape sequence and echo -n ([deb265c](https://github.com/jmarcelomb/.dotfiles/commit/deb265c584975a12fae1a1e0c5990f0a51f4a77d))
* set build type to Release for Neovim installation script ([16454f1](https://github.com/jmarcelomb/.dotfiles/commit/16454f10c0bd79983d08cb73502a9032a61315c3))
* update shebang in gen_commit_msg.py to use python3 ([761df37](https://github.com/jmarcelomb/.dotfiles/commit/761df3700534719f193474245be56f54ed436dc9))
