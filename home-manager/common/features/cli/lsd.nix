{
  programs.lsd = {
    enable = true;
    settings = {
      date = "+%e %b %H:%M";
      sorting.dir-grouping = "first";
      # this can make dir listing take a long time on large dirs
      # total-size =  true;
    };
  };
}
