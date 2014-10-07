package Games::NES::SpriteMaker;
use strict;
use warnings;

use Image::PNM;

sub image_to_sprite {
    my ($data) = @_;

    my $image = Image::PNM->new($data);
    if ($image->width % 8 || $image->height % 8) {
        die "Sprite collections must be tiles of 8x8 sprites (not "
          . $image->width . "x" . $image->height . ")";
    }
    my %colors = _get_palette_colors($image);

    my $sprite_x = $image->width / 8;
    my $sprite_y = $image->height / 8;

    my $bytes = '';
    for my $base_x (0..$sprite_x-1) {
        for my $base_y (0..$sprite_y-1) {
            for my $pixel_x ($base_x..$base_x + 7) {
                my $bits;
                for my $pixel_y ($base_y..$base_y + 7) {
                    my $pixel = $image->raw_pixel($pixel_y, $pixel_x);
                    my $pixel_value = $colors{_color_key($pixel)};
                    $bits .= $pixel_value & 0x01 ? "1" : "0";
                }
                $bytes .= pack("C", oct("0b$bits"));
            }
            for my $pixel_x ($base_x..$base_x + 7) {
                my $bits;
                for my $pixel_y ($base_y..$base_y + 7) {
                    my $pixel = $image->raw_pixel($pixel_y, $pixel_x);
                    my $pixel_value = $colors{_color_key($pixel)};
                    $bits .= $pixel_value & 0x02 ? "1" : "0";
                }
                $bytes .= pack("C", oct("0b$bits"));
            }
        }
    }

    return $bytes;
}

sub _get_palette_colors {
    my ($image) = @_;

    my %unique_values;
    my $idx = 0;
    for my $row (0..$image->height - 1) {
        for my $col (0..$image->width - 1) {
            my $pixel = $image->raw_pixel($row, $col);
            $unique_values{_color_key($pixel)} = $idx++
                unless defined $unique_values{_color_key($pixel)};
        }
    }

    if ($idx > 4) {
        die "Sprites can only use four colors";
    }

    return %unique_values;
}

sub _color_key {
    my ($pixel) = @_;
    return "$pixel->[0];$pixel->[1];$pixel->[2]";
}

1;
