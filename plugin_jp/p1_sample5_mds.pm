# R��vegan�ѥå������˴ޤޤ��metaMDS�ؿ���Ȥä�¿�������ٹ���ˡ��¹Ԥ���
# �ץ饰����Ǥ���

# ��Ω���ǤΡ�Useful R�ץ��꡼����10����R�Υѥå���������ӥġ���κ����ȱ��ѡ�
# ���ܥץ饰����β��⤬����ޤ���������C:\khcoder�ʳ���KH Coder�򥤥󥹥ȡ���
# ���Ƥ����꤬�Фʤ��褦�ˡ����ҷǺܤΥ����ɤˡ��㴳�դ�­���Ƥ��ޤ���

# �ץ饰���������
package p1_sample5_mds;

sub plugin_config{
	return {
		name     => '��и��¿�������ٹ���ˡ��metaMDS��',
		menu_grp => '����ץ�',
		menu_cnf => 2,
	};
}

# ��˥塼������˼¹Ԥ����롼����
sub exec{
	gui_window::mds->open;                        # �����̤򳫤�
}

# �����̤ν���
package gui_window::mds;
use base qw(gui_window);
my $selection;

sub _new{
	my $self = shift;
	
	$selection = gui_widget::words->open(         # ����ñ�̡��������
		parent => $self->win_obj,
		verb   => 'plot'
	);

	$self->win_obj->Button(                       # OK�ܥ������
		-text => 'OK',
		-command => sub{ $self->make_mds; }
	)->pack;

	return $self;
}

sub win_name{
	return 'w_plugin_mds';                        # ���̤μ����Ѥ�Ǥ�դ�̾����
}

# metaMDS�ؿ���Ȥä�MDS��¹�
sub make_mds{
	my $self = shift;
	                                              # ���ե�������ڤϥ���å���
	my $file_r   = 'plugin_jp/mds.r';             # *.r�ե������̾��
	my $file_pdf = 'mds.pdf';                     # ��¸����ե������̾��

	use Cwd;                                      # �ե�����̾��ե�ѥ���
	$file_r   = cwd.'/'.$file_r;
	$file_pdf = cwd.'/'.$file_pdf;

	my $r_command = mysql_crossout::r_com->new(   # �ǡ������Ф�
		$selection->params,
		rownames => 0,
	)->run;

	$r_command .= "\n";                           # R���ޥ�ɤν���
	$r_command .= "source(\"$file_r\")";

	my $plot = kh_r_plot->new(                    # ʬ�Ϥμ¹�
	  name      => 'plugin_mds',                  # �ʼ����Ѥ�Ǥ�դ�̾����
	  command_f => $r_command
	);

	$plot->save( $file_pdf );                     # PDF�ե�����˥ץ�åȤ���¸
	system("cmd /c start \"title\" \"$file_pdf\""); # ��¸����PDF�ե�����򳫤�

	$self->close;                                 # ������̤��Ĥ���
}

1;