package kh_plugin;

sub read{
	use File::Find;
	find(\&read_each, $::config_obj->cwd.'/plugin');
	
	sub read_each{
		return if(-d $File::Find::name);
		return unless $_ =~ /.+\.pm/;
		substr($_, length($_) - 3, length($_)) = '';
		print "$_\n";
		
		unless (eval "use $_; 1"){
			gui_errormsg->open(
				type => 'msg',
				msg  => "�ץ饰�����".$_.".pm�פ��ɤ߹��ߤ���ߤ��ޤ�����\n���顼���ơ�\n$@"
			);
			return 0;
		}
		
	}
}




1;