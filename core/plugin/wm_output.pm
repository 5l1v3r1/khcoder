package wm_output;
use strict;

#----------------------#
#   �ץ饰���������   #

sub plugin_config{
	return {
		name => '��ʸ�����и��ɽ�ظ�ˡ�ɽ�ν��� - ����ĹCSV��WordMiner��',
		menu_cnf => 0,
		menu_grp => '������',
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	gui_window::morpho_crossout::wm_output->open; # GUI��ư
}

#-----------------------------------#
#   GUI���Τ���Υ롼����ʷ���   #

# KH Coder�˴��˴ޤޤ�Ƥ���⥸�塼���gui_window::morpho_crossout�פ�����

package gui_window::morpho_crossout::wm_output;
use base qw(gui_window::morpho_crossout);
use strict;

sub save{
	my $self = shift;

	# �ʻ�����Υ����å�
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}

	# ��¸��λ���
	my @types = (
		['CSV Files',[qw/.csv/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.txt',
		-initialdir       => $::config_obj->cwd,
		-title            =>
			$self->gui_jchar('��ʸ�����и��ɽ��ɽ�ظ�ˡ�̾�����դ�����¸'),
		-filetypes        =>
			[
				['CSV Files', [qw/.csv/] ],
				['All files', '*'        ]
			],
	);
	return 0 unless $path;

	# �¹Գ�ǧ
	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�����Ǥ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	return 0 unless $ans =~ /ok/i;

	# �¹�
	my $w = gui_wait->start;
	mysql_crossout::var::hyoso->new(
		tani   => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		file   => $path,
	)->run;
	$w->end;

	$self->close;
}

sub label{
	return '��ʸ�����и��ɽ�ν��ϡ�ɽ�ظ�ˡ� ����ĹCSV';
}
sub win_name{
	return 'w_morpho_crossout_wm_output';
}

#------------------------------#
#   ���Ͻ����Τ���Υ롼����   #

# KH Coder�˴��˴ޤޤ�Ƥ���⥸�塼���mysql_crossout::var�פ�����

package mysql_crossout::var::hyoso;
use base qw(mysql_crossout::var);
use strict;

# SQLʸ�ν���(1)
sub sql3{
	my $self = shift;
	my $d1   = shift;
	my $d2   = shift;

	my $sql;
	$sql .= "SELECT $self->{tani}.id, hyoso.name, khhinshi.id\n";
	$sql .= "FROM   hyosobun, hyoso, genkei, khhinshi, $self->{tani}\n";
	$sql .= "WHERE\n";

	# �ơ��֥�η��
	$sql .= "	hyosobun.hyoso_id = hyoso.id\n";
	$sql .= "	AND hyoso.genkei_id = genkei.id\n";
	$sql .= "	AND genkei.khhinshi_id = khhinshi.id\n";
	my $flag = 0;
	foreach my $i ("bun","dan","h5","h4","h3","h2","h1"){
		if ($i eq $self->{tani}){ $flag = 1; }
		if ($flag){
			$sql .= "	AND hyosobun.$i"."_id = $self->{tani}.$i"."_id\n";
		}
	}

	# �Ǿ������硦�ֻ��Ѥ��ʤ���פΥ����å�
	$sql .= "	AND genkei.nouse = 0\n";
	$sql .= "	AND genkei.num >= $self->{min}\n";
	if ($self->{max}){
		$sql .= "	AND genkei.num <= $self->{max}\n";
	}

	# �ʻ�ˤ������
	$sql .= "	AND (\n";
	my $n = 0;
	foreach my $i ( @{$self->{hinshi}} ){
		if ($n){
			$sql .= '		OR ';
		} else {
			$sql .= "		";
		}
		$sql .= "khhinshi.id = $i\n";
		++$n;
	}
	$sql .= "	)\n";

	# �����ϰ�
	$sql .= "	AND $self->{tani}.id >= $d1\n";
	$sql .= "	AND $self->{tani}.id <  $d2\n";

	# ���Ͻ�
	$sql .= "ORDER BY hyosobun.id";

	return $sql;
}

# SQLʸ�ν���(2)
sub sql4{
	my $self = shift;
	my $d1   = shift;
	my $d2   = shift;

	my $sql;
	$sql .= "SELECT $self->{tani}.id, hyoso.name, genkei.nouse\n";
	$sql .= "FROM   hyosobun, hyoso, genkei, $self->{tani}\n";
	$sql .= "WHERE\n";

	# �ơ��֥�η��
	$sql .= "	hyosobun.hyoso_id = hyoso.id\n";
	$sql .= "	AND hyoso.genkei_id = genkei.id\n";
	my $flag = 0;
	foreach my $i ("bun","dan","h5","h4","h3","h2","h1"){
		if ($i eq $self->{tani}){ $flag = 1; }
		if ($flag){
			$sql .= "	AND hyosobun.$i"."_id = $self->{tani}.$i"."_id\n";
		}
	}

	# �����ϰ�
	$sql .= "	AND $self->{tani}.id >= $d1\n";
	$sql .= "	AND $self->{tani}.id <  $d2\n";

	# ���Ͻ�
	$sql .= "ORDER BY hyosobun.id";
	return $sql;
}

1;