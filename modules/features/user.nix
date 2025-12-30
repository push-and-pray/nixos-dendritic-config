{
  flake.lib = {
    admin = username: {
      users.users.${username}.extraGroups = ["wheel" "networkmanager"];
    };
  };
}
