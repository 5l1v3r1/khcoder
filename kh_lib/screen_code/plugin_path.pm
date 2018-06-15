package screen_code::plugin_path;
use strict;

use File::Path;
use File::Spec;
use Encode qw/encode decode/;

my $rde_name = File::Spec->catfile('screen', 'MonkinCleanser', 'MonkinCleanser.exe');
my $assistant_name = File::Spec->catfile('screen', 'MonkinReport', 'MonkinReport.exe');

sub rde_path{
	return encoding($rde_name);
}

sub assistant_path{
	return encoding($assistant_name);
}

#System関数に渡す時にOSによって文字コードを変える必要がある
sub encoding{
	my $plugin_name = shift;
	my $encode;
	if ($::config_obj->os eq 'win32') {
		$encode = 'cp932';
	} else {
		$encode = 'utf8';
	}
	return encode($encode, $plugin_name);
}

#オプションファイルを出力するフォルダのパス=プラグインのパス
sub assistant_option_folder{
	return $::config_obj->cwd."/screen/temp/";
}

1;