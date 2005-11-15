package gui_window::sql_select;
use base qw(gui_window);
use gui_jchar;
use gui_airborne;
use gui_hlist;
use mysql_exec;

use strict;
use Tk;
use Tk::HList;
use DBI;
use Jcode;

#----------------#
#   Window����   #
#----------------#

sub _new{
	
#--------------#
#   ������ʬ   #

	my $self = shift;
	my $win = $self->{win_obj};
	$win->title($self->gui_jchar('SQLʸ (SELECT) �¹�'));
	#$self->{win_obj} = $win;

	my $lf = $win->LabFrame(
		-label => 'Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both',-expand => 'y');

	my $t = $lf->Scrolled(
		'Text',
		-spacing1 => 0,
		-spacing2 => 0,
		-spacing3 => 0,
		-scrollbars=> 'osoe',
		-height => 8,
		-width => 48,
		-wrap => 'none',
		-font => "TKFN",
	)->pack(-fill=>'both',-expand=>'yes',-pady => 2);
	$t->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$t]);

	$lf->Label(
		-text => $self->gui_jchar('����ɽ����:'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');

	my $e = $lf->Entry(
		-font  => "TKFN",
		-width => 5,
	)->pack(-side => 'left');
	$e->insert(0,'1000');

	$lf->Button(
		-text    => $self->gui_jchar('�¹�'),
		-command => sub {$self->exec;},
		-font    => "TKFN"
	)->pack(-side => "right");


#----------------#
#   ���ɽ����   #

	my $plane = gui_airborne->make(
		parent      => $win,
		parent_name => $self->win_name,
		tower       => $lf,
		title       => $self->gui_jchar('SQLʸ (SELECT) ���'),
	);

	my $lf2 = $plane->frame->LabFrame(
		-label       => 'Result',
		-labelside   => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both',-expand => 'y');
	my $field = $lf2->Frame()->pack(-fill => 'both', -expand => 'y');

	my $list = $field->Scrolled('HList',
		-scrollbars       => 'osoe',
		-header           => '1',
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => '1',
		-padx             => '2',
		-background       => 'white',
		-height           => '4',
	)->pack(-fill=>'both',-expand => 'yes');

	my $frame = $lf2->Frame()->pack(-fill => 'x', -expand => '0');

	$frame->Button(
		-text    => $self->gui_jchar('���ԡ�'),
		-command => sub {gui_hlist->copy($self->list);},
		-font    => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');

	my $label = $frame->Label(
		-text => $self->gui_jchar('�����Ϥ��줿�Կ�: '),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');

	$plane->make_control($frame);

	$self->{entry} = $e;
	$self->{text}  = $t;
	$self->{list}  = $list;
	$self->{label} = $label;
	$self->{plane} = $plane;
	$self->{field} = $field;
	
	return $self;
}

#--------------#
#   ���٥��   #
#--------------#

#--------------#
#   �����¹�   #

sub exec{
	my $self = shift;
	
	my $all = Jcode->new(
		$self->gui_jg( $self->text->get("1.0","end") )
	)->euc;
	$all =~ s/\r\n/\n/g;
	my @temp = split /\;\n\n/, $all;
	
	my $t;
	foreach my $i (@temp){
		# SQL�¹�
		my $tc = mysql_exec->select($i);
		# ���顼�����å�
		if ( $tc->err ){
			my $msg = "SQLʸ�˥��顼������ޤ�����\n\n".$tc->err;
			my $w = $self->win_obj;
			gui_errormsg->open(
				type   => 'msg',
				msg    => $msg,
				window => \$w
			);
			return 0;
		}
		$t = $tc;
	}
	
	# ��̤ν񤭽Ф�
	$self->list->destroy;                                   # ����ʪ
	$self->{list} = $self->field->Scrolled('HList',
		-scrollbars       => 'oe',
		-header           => '1',
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => $t->hundle->{NUM_OF_FIELDS},
		-padx             => '2',
		-background       => 'white',
		-height           => '4',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'extended'
	)->pack(-fill=>'both',-expand => 'yes');
	my $n = 0;
	foreach my $i (@{$t->hundle->{NAME}}){
		$self->list->header('create',$n,-text => $i);
		++$n;
	}
	
	my $row = 0;                                            # ���
	my $max = $self->max; my $frag = 0;
	while (my $i = $t->hundle->fetch){
		$self->list->add($row,-at => "$row");
		my $col = 0;
		foreach my $h (@{$i}){
			$self->list->itemCreate($row,$col,-text => $self->gui_jchar($h)); # nkf('-s -E',$h)
			++$col;
		}
		++$row;
		if ($row == $max){
			$frag = 1;
			last;
		}
	}
	if ($frag){                                             # ���ϹԿ��������
		while (my $i = $t->hundle->fetch){
			++$row;
		}
	}
	$self->label->configure(-text,$self->gui_jchar('���Ϥ��줿�Կ�: '."$row"));
	
	$self->plane->frame->focus;
}


sub close{
	my $self = shift;
	$self->plane->close;
}

sub start{
	my $self = shift;
	$self->plane->start;
	$self->text->focus;
}
#--------------#
#   ��������   #
#--------------#

sub max{
	my $self = shift;
	return $self->{entry}->get;
}

sub text{
	my $self = shift;
	return $self->{text};
}

sub list{
	my $self = shift;
	return $self->{list};
}

sub field{
	my $self = shift;
	return $self->{field};
}

sub label{
	my $self = shift;
	return $self->{label};
}


sub win_name{
	return 'w_tool_sql_select';
}

sub plane{
	my $self = shift;
	return $self->{plane};
}


1;
