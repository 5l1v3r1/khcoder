package gui_widget::bubble;
use base qw(gui_widget);
use strict;
use Tk;
use Jcode;

sub _new{
	my $self = shift;
	
	my $win = $self->parent->Frame();
	
	
	my $f1 = $win->Frame()->pack(-fill => 'x');
	
	$f1->Checkbutton(
		-text     => gui_window->gui_jchar('�Х֥�ץ�åȡ�'),
		-variable => \$self->{check_bubble},
		-command  => sub{ $self->refresh_std_radius;},
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);

	$self->{lab_size1} = $f1->Label(
		-text => gui_window->gui_jchar('�Х֥���礭��'),
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{ent_size} = $f1->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_size}->insert(0,'100');
	gui_window->config_entry_focusin($self->{ent_size});

	$self->{lab_size2} = $f1->Label(
		-text => '%',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');


	if ($self->{type} eq 'corresp'){
		my $frm_std_radius = $win->Frame()->pack(
			-fill => 'x',
		);

		$frm_std_radius->Label(
			-text => '  ',
			-font => "TKFN",
		)->pack(-anchor => 'w', -side => 'left');

		$self->{chk_resize_vars} = 1;
		$self->{chkw_resize_vars} = $frm_std_radius->Checkbutton(
				-text     => gui_window->gui_jchar('�ѿ����� / ���Ф����礭������Ѥ�','euc'),
				-variable => \$self->{chk_resize_vars},
				-anchor => 'w',
				-state => 'disabled',
		)->pack(-anchor => 'w');
	}

	my $f2 = $win->Frame()->pack(
		-fill => 'x',
	);

	$f2->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{chk_std_radius} = 1;
	$self->{chkw_std_radius} = $f2->Checkbutton(
		-text     => gui_window->gui_jchar('�Х֥���礭����ɸ�ಽ��','euc'),
		-variable => \$self->{chk_std_radius},
		-anchor => 'w',
		-state => 'disabled',
	)->pack(-anchor => 'w', -side => 'left');

	$self->{lab_var1} = $f2->Label(
		-text => gui_window->gui_jchar('ʬ��'),
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{ent_var} = $f2->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_var}->insert(0,'100');
	gui_window->config_entry_focusin($self->{ent_var});


	$self->{lab_var2} = $f2->Label(
		-text => '%',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');


	$self->refresh_std_radius;
	$self->{win_obj} = $win;
	return $self;
}

sub refresh_std_radius{
	my $self = shift;
	
	my @temp = (
		$self->{chkw_std_radius},
		$self->{chkw_resize_vars},
		$self->{lab_size1},
		$self->{lab_size2},
		$self->{ent_size},
		$self->{lab_vaar1},
		$self->{lab_var2},
		$self->{ent_var},
	);
	
	my $state = 'disabled';
	$state = 'normal' if $self->{check_bubble};
	
	foreach my $i (@temp){
		$i->configure(-state => $state) if $i;
	} 

}


#----------------------#
#   ����ؤΥ�������   #

sub check_bubble{
	my $self = shift;
	return gui_window->gui_jg( $self->{check_bubble} );
}

sub chk_resize_vars{
	my $self = shift;
	return gui_window->gui_jg( $self->{check_bubble} );
}

sub chk_std_radius{
	my $self = shift;
	return gui_window->gui_jg( $self->{chk_resize_vars} );
}

sub size{
	my $self = shift;
	return gui_window->gui_jg( $self->{ent_size}->get );
}

sub var{
	my $self = shift;
	return gui_window->gui_jg( $self->{ent_var}->get );
}



1;