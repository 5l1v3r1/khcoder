package gui_window::cod_corresp_plot;
use base qw(gui_window);

use strict;
use gui_hlist;
use mysql_words;

sub _new{
	if ($::config_obj->os eq 'linux') {
		require Tk::PNG;
	}

	my $self = shift;

	my %args = @_;
	$self->{plots} = $args{plots};
	
	my $mw = $::main_gui->mw;
	my $win= $self->{win_obj};
	$win->title($self->gui_jt('�����ǥ��󥰡��б�ʬ��'));

	$self->{photo} = $win->Label(
		-image => $win->Photo(-file => $self->{plots}[$self->{ax}]->path),
		-borderwidth => 2,
		-relief => 'sunken',
	)->pack(-anchor => 'c');

	my $f1 = $win->Frame()->pack(
		-expand => 1,
		-fill   => 'x',
		-pady   => 2,
		-padx   => 2,
		-anchor => 's',
	);

	$f1->Label(
		-text => $self->gui_jchar(' ɽ����'),
		-font => "TKFN",
	)->pack(-side => 'left');
	
	$self->{optmenu} = gui_widget::optmenu->open(
		parent  => $f1,
		pack    => {-side => 'left'},
		options =>
			[
				[$self->gui_jchar('������̾','euc'), 0],
				[$self->gui_jchar('������̾�ȥɥå�','euc'), 1],
			],
		variable => \$self->{ax},
		command  => sub {$self->renew;},
	);
	$self->{optmenu}->set_value(0);

	if (length($args{stress})){
		$f1->Label(
			-text => "   Stress = ".$args{stress}
		)->pack(-side => 'left');
	}

	$f1->Button(
		-text => $self->gui_jchar('�Ĥ���'),
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after
			(
				10,
				sub {
					$self->close();
				}
			);
		}
	)->pack(-side => 'right');

	$f1->Button(
		-text => $self->gui_jchar('��¸'),
		-font => "TKFN",
		#-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after
			(
				10,
				sub {
					$self->save();
				}
			);
		}
	)->pack(-side => 'right',-padx => 4);

	return $self;
}

sub renew{
	my $self = shift;
	return 0 unless $self->{optmenu};
	
	#print "selection: $self->{ax}\n";
	
	$self->{photo}->configure(
		-image => $self->{win_obj}->Photo(-file => $self->{plots}[$self->{ax}]->path)
	);
	$self->{photo}->update;
}

sub save{
	my $self = shift;

	# ��¸��λ���
	my @types = (
		[ "Encapsulated PostScript",[qw/.eps/] ],
		#[ "Adobe PDF",[qw/.pdf/] ],
		[ "PNG",[qw/.png/] ],
		[ "R Source",[qw/.r/] ],
	);
	@types = ([ "Enhanced Metafile",[qw/.emf/] ], @types)
		if $::config_obj->os eq 'win32';

	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.eps',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt('�ץ�åȤ���¸'),
		-initialdir       => $self->gui_jchar($::config_obj->cwd)
	);

	$path = $self->gui_jg_filename_win98($path);
	$path = $self->gui_jg($path);
	$path = $::config_obj->os_path($path);

	$self->{plots}[$self->{ax}]->save($path) if $path;

	return 1;
}

#--------------#
#   ��������   #


sub win_name{
	return 'w_cod_corresp_plot';
}

1;