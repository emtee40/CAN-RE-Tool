#!/usr/bin/perl

package CRT::Display::Uniques;

my $pkg = __PACKAGE__;
use base (Exporter);

use CRT::Messages;

use vars qw
  {
  $cui
  $window
  $text
  $updated
  };

sub new
  {
  my $class = shift;
  $class = ref($class) || $class;
  my $self = {@_};
  bless( $self, $class );

  $self->{'updated'} = 0;

  return $self;
  }

sub name
  {
  return "Messages: Uniques";
  }

sub select
  {
  my ($self,$cui,$window) = @_;

  $self->{'cui'} = $cui;
  $self->{'window'} = $window;

  $window->title('Messages: Uniques');
  $self->{'text'} = $window->add("text", "TextViewer", -text => "");

  CRT::Messages::register_listener('CRT::Display::Uniques',$self);
  }

sub deselect
  {
  my ($self,$cui,$window) = @_;

  $window->delete("text");
  undef $self->{'text'};

  CRT::Messages::unregister_listener('CRT::Display::Uniques');
  }

sub incomingmessage
  {
  my ($self,$msg) = @_;

  $self->{'updated'}++;

  return undef;
  }

sub update
  {
  my ($self,$cui,$window) = @_;

  $self->{'updated'} = 0;

  my ($u) = CRT::Messages::uniques_refs();

  my @msgs = ();

  foreach (sort keys %{$u})
    {
    my ($uk,$uv) = ($_,$u->{$_});

    my ($dsec,$dms,$type,$id,@bytes) = split ',',$uv;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime $dsec;
    my $stamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d.%03d",$year+1900,$mon+1,$mday,$hour,$min,$sec,$dms);

    my (@p_a,@p_h);
    foreach (0..7)
      {
      push @p_h,(defined $bytes[$_])?sprintf("%02.2x",$bytes[$_]):"  ";
      my $b = (defined $bytes[$_])?chr($bytes[$_]):chr(0);
      push @p_a, ($b =~ /[[:print:]]/)?$b:'.';
      }

    my ($un,$ua) = CRT::Messages::uniques_counts($uk);

    my @decodes = ();
    if ($uk ne '')
      {
      my $d = CRT::Messages::uniques_decodes_ref($uk);
      foreach (sort keys %{$d})
        { push @decodes,$_.':'.$d->{$_}; }
      }

    push @msgs,sprintf("%-30.30s [ %-5d %10dms ] %s %s %03.3x %s %s %s",$uk,$un,$ua,$stamp,$type,$id,join(' ',@p_h),join('',@p_a),join(' ',@decodes));
    }

  $self->{'text'}->text(join("\n",@msgs));
  $self->{'text'}->draw();
  Curses::curs_set(1);
  }

1;
