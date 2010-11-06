package BatchEncoder;
use strict;
use warnings;
use HandBrake;
use Path::Class;
use Data::Dumper;
use FileTransfer;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    
    $self->{input} = dir(shift || 'recording');
    $self->{stage} = dir(shift || 'staging');
    $self->{output} = dir(shift || 'encoded');
    $self->{input_ext} = shift || '.ts';
    $self->{output_ext} = shift || '.mkv';
    $self->{tool} = HandBrake->new("384","224");
    $self->{host} = shift || '';
    $self->{user} = shift || '';
    $self->{password} = shift || '';
    $self->{remote_dir} = shift || '';
    
    return $self;
}

sub run
{
    my ($self,$delay) = @_;
    $delay = $delay || 10;
    while(1)
    {
        $self->move_to_staging();
        $self->encode_files();
        $self->upload_files();
        sleep $delay;
	exit;
    }
}

sub encode_files
{
    my $self = shift;
    while(my $source_file = $self->{stage}->next())
    {
	if (-f $source_file) {
	    printf "Encoding %s ...\n",$source_file;
	    my $dest_file = $source_file->basename();
	    $dest_file =~ s/\s//;
	    $dest_file =~ s/\.[a-zA-Z0-9]{2,4}$/$self->{output_ext}/;
	    $self->{tool}->convert($source_file,file($self->{output},$dest_file));
	}
    }

}

sub upload_files
{
    my $self = shift;
    while(my $encoded_file = $self->{output}->next())
    {
	if (-f $encoded_file)
	{
	    my $ft = FileTransfer->new('scp',$self->{host},$self->{user},$self->{password});
	    $ft->copy($encoded_file,$self->{remote_dir});
	    printf "Transfering %s ...\n",$encoded_file;
	}
	
    }
}

sub move_to_staging
{    
    my $self = shift;
    while(my $input_file = $self->{input}->next())
    {
	printf "Testing %s %s %d\n",$input_file,-s $input_file,600*1000*100;
	if (-s $input_file > 600*1000*1000) {
            print "Move $input_file\n";
	    #system("move \"$input_file\" $self->{stage}");
        }
    }
}


1;
