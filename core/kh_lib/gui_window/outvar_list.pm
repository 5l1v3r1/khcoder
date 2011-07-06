package gui_window::outvar_list;
use base qw(gui_window);
use strict;
use Tk;

use mysql_outvar;

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $self->{win_obj};
	#$wmw->focus;
	$wmw->title($self->gui_jt('�����ѿ��ꥹ��'));

	my $fra4 = $wmw->LabFrame(
		-label => 'Variables',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'both', -expand => 'yes');

	my $lis = $fra4->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 2,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectborderwidth=> 0,
		-selectmode       => 'extended',
		-command          => sub {$self->_open_var;},
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => $self->gui_jchar('����ñ��'));
	$lis->header('create',1,-text => $self->gui_jchar('�ѿ�̾'));

	$wmw->Button(
		-text => $self->gui_jchar('�ܺ�'),
		-font => "TKFN",
#		-width => 8,
		-command => sub{$self->_open_var;}
	)->pack(-side => 'left');

	$wmw->Button(
		-text => $self->gui_jchar('����'),
		-font => "TKFN",
#		-width => 8,
		-command => sub{$self->_save;}
	)->pack(-side => 'left');

	$wmw->Label(
		-text => '  ',
	)->pack(-side => 'left');

	$wmw->Button(
		-text => $self->gui_jchar('���'),
		-font => "TKFN",
#		-width => 8,
		-command => sub{$self->_delete;}
	)->pack(-side => 'left',-padx => 2);

	$wmw->Button(
		-text => $self->gui_jchar('�Ĥ���'),
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->close;}
	)->pack(-side => 'right',-padx => 2);

	#MainLoop;
	
	$self->{list}    = $lis;
	#$self->{win_obj} = $wmw;
	$self->_fill;
	return $self;
}

#--------------------#
#   �ե��󥯥����   #
#--------------------#

sub _fill{
	my $self = shift;
	
	my $h = mysql_outvar->get_list;
	
	$self->{list}->delete('all');
	my $n = 0;
	foreach my $i (@{$h}){
		if ($i->[0] eq 'dan'){$i->[0] = '����';}
		if ($i->[0] eq 'bun'){$i->[0] = 'ʸ';}
		$self->{list}->add($n,-at => "$n");
		$self->{list}->itemCreate($n,0,-text => $self->gui_jchar($i->[0]),);
		$self->{list}->itemCreate($n,1,-text => $self->gui_jchar($i->[1]),);
		++$n;
		# my $chk = Jcode->new($i->[1])->icode;
		# print "$chk, $i->[1]\n";
	}
	$self->{var_list} = $h;
	return $self;
}

sub _delete{
	my $self = shift;
	my %args = @_;
	
	# �����ǧ
	my @selection = $self->{list}->info('selection');
	unless (@selection){
		gui_errormsg->open(
			type => 'msg',
			msg  => '��������ѿ������򤷤Ƥ���������',
		);
		return 0;
	}
	
	# �����˺������Τ���ǧ
	unless ( $args{no_conf} ){
		my $confirm = $self->{win_obj}->messageBox(
			-title   => 'KH Coder',
			-type    => 'OKCancel',
			#-default => 'OK',
			-icon    => 'question',
			-message => $self->gui_jchar('���򤵤�Ƥ����ѿ��������ޤ�����'),
		);
		unless ($confirm =~ /^OK$/i){
			return 0;
		}
	}
	
	# ���˾ܺ�Window�������Ƥ�����Ϥ��ä����Ĥ���
	$::main_gui->get('w_outvar_detail')->close
		if $::main_gui->if_opened('w_outvar_detail');
	
	# ����¹�
	foreach my $i (@selection){
		mysql_outvar->delete(
			tani => $self->{var_list}[$i][0],
			name => $self->{var_list}[$i][1],
		);
	}
	$self->_fill;
}

sub _save{
	my $self = shift;
	
	# �����ǧ
	my @selection = $self->{list}->info('selection');
	unless (@selection){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���Ϥ����ѿ������򤷤Ƥ���������',
		);
		return 0;
	}
	my @vars = (); my $last = '';
	foreach my $i (@selection){
		push @vars, $self->{var_list}[$i][1];
		
		$last = $self->{var_list}[$i][0] unless length($last);
		
		unless ($last eq $self->{var_list}[$i][0]){
			gui_errormsg->open(
				type => 'msg',
				msg  => '����ñ�̤ΰۤʤ��ѿ�������٤���¸���뤳�ȤϤǤ��ޤ���',
			);
			return 0;
		}
	}

	# ��¸��ե�����̾
	my @types = (
		['CSV Files',[qw/.csv/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.csv',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt('��ʸ�����и��ɽ��̾�����դ�����¸'),
		-initialdir       => $self->gui_jchar($::config_obj->cwd)
	);
	unless ($path){
		return 0;
	}
	$path = gui_window->gui_jg_filename_win98($path);
	$path = gui_window->gui_jg($path);
	$path = $::config_obj->os_path($path);

	mysql_outvar->save(
		path => $path,
		vars => \@vars,
	);

	return 1;
}


sub _open_var{
	my $self = shift;
	
	my @selection = $self->{list}->info('selection');
	unless (@selection){
		return 0;
	}
	
	# ���˾ܺ�Window�������Ƥ�����Ϥ��ä����Ĥ���
	$::main_gui->get('w_outvar_detail')->close
		if $::main_gui->if_opened('w_outvar_detail');

	gui_window::outvar_detail->open(
		tani => $self->{var_list}[$selection[0]][0],
		name => $self->{var_list}[$selection[0]][1],
	);

}

#--------------#
#   ��������   #
#--------------#


sub win_name{
	return 'w_outvar_list';
}


1;
