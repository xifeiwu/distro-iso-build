#!/usr/bin/perl

#use LWP::Simple;

$repo_conf = "/etc/apt/sources.list.d/";
$list_file_name = "official-package-repositories.list";
$list_file = $repo_conf.$list_file_name;

$repo_url = "124.16.141.149";
$url_head = "deb http://";
$repo_addr = 
"$url_head$repo_url/repos/cos cos main
$url_head$repo_url/repos/mint olivia main upstream import
$url_head$repo_url/repos/ubuntu raring main restricted universe multiverse
$url_head$repo_url/repos/ubuntu raring-security main restricted universe multiverse
$url_head$repo_url/repos/ubuntu raring-updates main restricted universe multiverse
$url_head$repo_url/repos/ubuntu raring-proposed main restricted universe multiverse
$url_head$repo_url/repos/ubuntu raring-backports main restricted universe multiverse
$url_head$repo_url/repos/security-ubuntu/ubuntu raring-security main restricted universe multiverse
$url_head$repo_url/repos/canonical/ubuntu raring partner
";
$tmp = "/tmp/cos.key";
$dld_gpg = "wget -O $tmp http://$repo_url/repos/cos.gpg.key";
$add_gpg = "sudo apt-key add $tmp";
$update_list = "sudo apt-get update";

#Delete old list file and create a new one
if (-e $list_file){
    unlink($list_file) or die "$!, Try root first!";
    open(FILE_H, ">$list_file") or die "$!, Try root first!";
} else {
    open(FILE_H, ">$list_file") or die "$!, Try root first!";
}

#Write to list file
print FILE_H $repo_addr;

#Download gpg public key
system($dld_gpg);
system($add_gpg);
system($update_list);
