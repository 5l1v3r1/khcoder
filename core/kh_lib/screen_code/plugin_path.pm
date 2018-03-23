package screen_code::plugin_path;
use strict;

use encoding "cp932";
use File::Path;
use File::Spec;
use Encode qw/encode decode/;

my $rde_name = File::Spec->catfile('screen', 'MonkinCleanser', 'MonkinCleanser.exe');
my $assistant_name = File::Spec->catfile('screen', 'MonkinReporter', 'MonkinReporter.exe');

sub rde_path{
	return $rde_name;
}

sub rde_path_system{
	return encoding($rde_name);
}

sub assistant_path{
	return $assistant_name;
}

sub assistant_path_system{
	return encoding($assistant_name);
}

#System�֐��ɓn������OS�ɂ���ĕ����R�[�h��ς���K�v������
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

#�I�v�V�����t�@�C�����o�͂���t�H���_�̃p�X=�v���O�C���̃p�X
sub assistant_option_folder{
	return $::config_obj->cwd."/screen/temp/";
}

1;