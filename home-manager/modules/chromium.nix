{
  programs.chromium = {
    enable = true;
    extensions = [
      # Dark Reader
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }

      # Unhook - Remove YouTube Recommended & Shorts
      { id = "khncfooichmfjbepaaaebmommgaepoid"; }

      # FireShot
      { id = "mcbpblocgmgfnpjjppndjkmgjaogfceg"; }
    ];
  };
}
