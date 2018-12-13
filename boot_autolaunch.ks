// setup system and launch
switch to 0.
run setup.
delete core:bootfilename.
wait 5.
core:part:getmodule("kOSProcessor"):doevent("open terminal").
run launch.
run post_launch.
