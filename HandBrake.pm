package HandBrake;
use strict;
use warnings;
use IPC::Open3;
use IO::Select; # for select
use Data::Dumper;
use Symbol; # for gensym

sub new {
    my ($class,$maxwidth,$maxheight,$acodec,$vcodec,
        $rate,$abitrate,$vbitrate,$other_options) = @_;
    
    my $self = bless {}, $class;
    
    $self->{maxwidth} = $maxwidth;
    $self->{maxheight} = $maxheight;
    $self->{acodec}= $acodec || 'faac';
    $self->{vcodec} = $vcodec || 'x264';
    $self->{arate} = $abitrate || 96;
    $self->{vrate} = $vbitrate || 388;
    $self->{format} = 'mkv';
    $self->{rate} = $rate || 25;
    
    $self->{other_options} = $other_options || '';
    $self->{hbcli} = $ENV{HBCLI} || 'HandBrakeCLI';

    return $self;
}

sub convert
{
    my ($self,$source,$dest) = @_;
    $|=0;
    
    my $args = $self->make_args($source,$dest);
    print "$self->{hbcli} $args \n";
    open my $fh,"|$self->{hbcli} $args |" or die "unable to run $!";
    while(my $line = <$fh>){
                print $line;
    }
    close $fh;
}

sub make_args
{
    my ($self,$source,$dest) = @_;
    return sprintf(" -i \"%s\" -o %s -v 7 -f %s -r %s -b %s -B %s -E %s -e %s -2 -O -X %s -Y %s %s",
                   $source,$dest,$self->{format},
                   $self->{rate},$self->{vrate},$self->{arate},$self->{acodec},
                   $self->{vcodec},$self->{maxwidth},$self->{maxheight},
                   $self->{other_options});
}
1;
