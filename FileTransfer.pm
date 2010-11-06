package FileTransfer;
use strict;
use warnings;

sub new {
    my ($class,$type,$host,$user,$password) = @_;
    my $self = bless {}, $class;
    $self->{host} = $host;
    $self->{type} = $type || 'scp';
    $self->{user} = $user || 'root';
    $self->{password} = $password;
    $self->set_tool();
    return $self;
}

sub set_tool
{
    my $self = shift;
    if ($self->{type} eq 'scp')
    {
        $self->{tool} = 'pscp';
        $self->{args} = " -batch -C -l %s -pw %s %s %s:%s";
        ;
    }
    
    if ($self->{type} eq 'rsync')
    {
        $self->{tool} = 'rsync';
    }
}

sub make_args
{
    my ($self,$source,$dest) = @_;
    return sprintf "$self->{args}",$self->{user},$self->{password},
                    $source,$self->{host},$dest;
}

sub copy
{
    my ($self,$source,$dest) = @_;
    $|=0;
    my $args = $self->make_args($source,$dest);
    print "$self->{tool} $args \n";
    open my $fh,"| $self->{tool} $args |" or die "unable to run $!";
    while(my $line = <$fh>){
        print $line;
    }
    close $fh;
    
}
1;
