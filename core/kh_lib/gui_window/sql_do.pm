package gui_window::sql_do;
use base qw(gui_window);
use gui_jchar;
# use gui_airborne;
use mysql_exec;

use strict;
use Tk;
# use Tk::HList;
use DBI;
# use DBD::MySQL;
# use NKF;

#----------------#
#   Window����   #
#----------------#

sub _new{
	my $self = shift;
	my $win = $self->{win_obj};
	$win->title($self->gui_jchar('SQLʸ (����¾) �¹�'));
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
	# �ɥ�å����ɥ�å�
	$t->DropSite(
		-dropcommand => [\&Gui_DragDrop::read_TextFile_droped,$t],
		-droptypes => ($^O eq 'MSWin32' ? 'Win32' : ['XDND', 'Sun'])
	);

	$win->Label(
		-text => 'Status:',
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left', -padx => 2);

	$self->{label} = $win->Label(
		-text       => 'Ready',
		-font       => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w', -side => 'left');

	$win->Button(
		-text    => $self->gui_jchar('�¹�'),
		-command => sub {$self->exec;},
		-font    => "TKFN"
	)->pack(-side => "right",-padx => 2,-pady =>2);
	
	$self->{text} = $t;
	return $self;
}

#--------------#
#   ���٥��   #

sub exec{
	my $self = shift;
	$self->label->configure(-foreground => 'red',-text => 'Running...');
	$self->win_obj->update;
	
	my $all = Jcode->new(
		$self->gui_jg(
			$self->text->get("1.0","end"),
			'sjis'
		)
	)->euc;
	$all =~ s/\r\n/\n/g;
	my @temp = split /\;\n\n/, $all;
	foreach my $i (@temp){
		#print "$i\n";
		# SQL�¹�
		my $t = mysql_exec->do($i);
		
		# ���顼�����å�
		if ( $t->err ){
			my $msg = "SQLʸ�˥��顼������ޤ�����\n\n".$t->err;
			my $w = $self->win_obj;
			gui_errormsg->open(
				type   => 'msg',
				msg    => $msg,
				window => \$w
			);
			$self->label->configure(-foreground => 'black',-text => 'Ready (last quely failed)');
			$self->win_obj->update;
			return 0;
		}
	}

	$self->label->configure(-foreground => 'blue',-text => 'Ready');
	$self->win_obj->update;
}


#--------------#
#   ��������   #

sub label{
	my $self = shift;
	return $self->{label};
}
sub text{
	my $self = shift;
	return $self->{text};
}

sub win_name{
	return 'w_tool_sql_do';
}

sub start{
	my $self = shift;
	$self->text->focus;
}
1;
