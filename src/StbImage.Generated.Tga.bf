// Generated by Sichem at 14.02.2020 1:27:28

namespace StbImageSharp
{
	extension StbImage
	{
		public static int stbi__tga_get_comp(int bits_per_pixel, int is_grey, int* is_rgb16)
		{
			if (is_rgb16 != null)
				*is_rgb16 = 0;
			switch (bits_per_pixel)
			{
				case 8:
					return STBI_grey;
				case 15:
				case 16:
					if (bits_per_pixel == 16 && is_grey != 0)
						return STBI_grey_alpha;
					if (is_rgb16 != null)
						*is_rgb16 = 1;
					return STBI_rgb;
				case 24:
				case 32:
					return bits_per_pixel / 8;
				default:
					return 0;
			}
		}

		public static int stbi__tga_info(stbi__context s, int* x, int* y, int* comp)
		{
			var tga_w = 0;
			var tga_h = 0;
			var tga_comp = 0;
			var tga_image_type = 0;
			var tga_bits_per_pixel = 0;
			var tga_colormap_bpp = 0;
			var sz = 0;
			var tga_colormap_type = 0;
			stbi__get8(s);
			tga_colormap_type = stbi__get8(s);
			if (tga_colormap_type > 1)
			{
				stbi__rewind(s);
				return 0;
			}

			tga_image_type = stbi__get8(s);
			if (tga_colormap_type == 1)
			{
				if (tga_image_type != 1 && tga_image_type != 9)
				{
					stbi__rewind(s);
					return 0;
				}

				stbi__skip(s, 4);
				sz = stbi__get8(s);
				if (sz != 8 && sz != 15 && sz != 16 && sz != 24 && sz != 32)
				{
					stbi__rewind(s);
					return 0;
				}

				stbi__skip(s, 4);
				tga_colormap_bpp = sz;
			}
			else
			{
				if (tga_image_type != 2 && tga_image_type != 3 && tga_image_type != 10 && tga_image_type != 11)
				{
					stbi__rewind(s);
					return 0;
				}

				stbi__skip(s, 9);
				tga_colormap_bpp = 0;
			}

			tga_w = stbi__get16le(s);
			if (tga_w < 1)
			{
				stbi__rewind(s);
				return 0;
			}

			tga_h = stbi__get16le(s);
			if (tga_h < 1)
			{
				stbi__rewind(s);
				return 0;
			}

			tga_bits_per_pixel = stbi__get8(s);
			stbi__get8(s);
			if (tga_colormap_bpp != 0)
			{
				if (tga_bits_per_pixel != 8 && tga_bits_per_pixel != 16)
				{
					stbi__rewind(s);
					return 0;
				}

				tga_comp = stbi__tga_get_comp(tga_colormap_bpp, 0, null);
			}
			else
			{
				tga_comp = stbi__tga_get_comp(tga_bits_per_pixel, tga_image_type == 3 || tga_image_type == 11 ? 1 : 0,
					null);
			}

			if (tga_comp == 0)
			{
				stbi__rewind(s);
				return 0;
			}

			if (x != null)
				*x = tga_w;
			if (y != null)
				*y = tga_h;
			if (comp != null)
				*comp = tga_comp;
			return 1;
		}

		public static int stbi__tga_test(stbi__context s)
		{
			var res = 0;
			var sz = 0;
			var tga_color_type = 0;
			stbi__get8(s);
			tga_color_type = stbi__get8(s);
			if (tga_color_type > 1)
				goto errorEnd;
			sz = stbi__get8(s);
			if (tga_color_type == 1)
			{
				if (sz != 1 && sz != 9)
					goto errorEnd;
				stbi__skip(s, 4);
				sz = stbi__get8(s);
				if (sz != 8 && sz != 15 && sz != 16 && sz != 24 && sz != 32)
					goto errorEnd;
				stbi__skip(s, 4);
			}
			else
			{
				if (sz != 2 && sz != 3 && sz != 10 && sz != 11)
					goto errorEnd;
				stbi__skip(s, 9);
			}

			if (stbi__get16le(s) < 1)
				goto errorEnd;
			if (stbi__get16le(s) < 1)
				goto errorEnd;
			sz = stbi__get8(s);
			if (tga_color_type == 1 && sz != 8 && sz != 16)
				goto errorEnd;
			if (sz != 8 && sz != 15 && sz != 16 && sz != 24 && sz != 32)
				goto errorEnd;
			res = 1;
			errorEnd:
			;
			stbi__rewind(s);
			return res;
		}

		public static void stbi__tga_read_rgb16(stbi__context s, uint8* _out_)
		{
			var px = (uint16)stbi__get16le(s);
			var fiveBitMask = (uint16)31;
			var r = (px >> 10) & fiveBitMask;
			var g = (px >> 5) & fiveBitMask;
			var b = px & fiveBitMask;
			_out_[0] = (uint8)(r * 255 / 31);
			_out_[1] = (uint8)(g * 255 / 31);
			_out_[2] = (uint8)(b * 255 / 31);
		}

		public static void* stbi__tga_load(stbi__context s, int* x, int* y, int* comp, int req_comp,
			stbi__result_info* ri)
		{
			var tga_offset = (int)stbi__get8(s);
			var tga_indexed = (int)stbi__get8(s);
			var tga_image_type = (int)stbi__get8(s);
			var tga_is_RLE = 0;
			var tga_palette_start = stbi__get16le(s);
			var tga_palette_len = stbi__get16le(s);
			var tga_palette_bits = (int)stbi__get8(s);
			var tga_x_origin = stbi__get16le(s);
			var tga_y_origin = stbi__get16le(s);
			var tga_width = stbi__get16le(s);
			var tga_height = stbi__get16le(s);
			var tga_bits_per_pixel = (int)stbi__get8(s);
			var tga_comp = 0;
			var tga_rgb16 = 0;
			var tga_inverted = (int)stbi__get8(s);
			uint8* tga_data;
			uint8* tga_palette = null;
			var i = 0;
			var j = 0;
			var raw_data = scope uint8[4];
			raw_data[0] = 0;

			var RLE_count = 0;
			var RLE_repeating = 0;
			var read_next_pixel = 1;
			if (tga_image_type >= 8)
			{
				tga_image_type -= 8;
				tga_is_RLE = 1;
			}

			tga_inverted = 1 - ((tga_inverted >> 5) & 1);
			if (tga_indexed != 0)
				tga_comp = stbi__tga_get_comp(tga_palette_bits, 0, &tga_rgb16);
			else
				tga_comp = stbi__tga_get_comp(tga_bits_per_pixel, tga_image_type == 3 ? 1 : 0, &tga_rgb16);
			if (tga_comp == 0)
				return (uint8*)(stbi__err("bad format") != 0 ? (uint8*)null : null);
			*x = tga_width;
			*y = tga_height;
			if (comp != null)
				*comp = tga_comp;
			if (stbi__mad3sizes_valid(tga_width, tga_height, tga_comp, 0) == 0)
				return (uint8*)(stbi__err("too large") != 0 ? (uint8*)null : null);
			tga_data = (uint8*)stbi__malloc_mad3(tga_width, tga_height, tga_comp, 0);
			if (tga_data == null)
				return (uint8*)(stbi__err("outofmem") != 0 ? (uint8*)null : null);
			stbi__skip(s, tga_offset);
			if (tga_indexed == 0 && tga_is_RLE == 0 && tga_rgb16 == 0)
			{
				for (i = 0; i < tga_height; ++i)
				{
					var row = tga_inverted != 0 ? tga_height - i - 1 : i;
					var tga_row = tga_data + row * tga_width * tga_comp;
					stbi__getn(s, tga_row, tga_width * tga_comp);
				}
			}
			else
			{
				if (tga_indexed != 0)
				{
					stbi__skip(s, tga_palette_start);
					tga_palette = (uint8*)stbi__malloc_mad2(tga_palette_len, tga_comp, 0);
					if (tga_palette == null)
					{
						CRuntime.free(tga_data);
						return (uint8*)(stbi__err("outofmem") != 0 ? (uint8*)null : null);
					}

					if (tga_rgb16 != 0)
					{
						var pal_entry = tga_palette;
						for (i = 0; i < tga_palette_len; ++i)
						{
							stbi__tga_read_rgb16(s, pal_entry);
							pal_entry += tga_comp;
						}
					}
					else if (stbi__getn(s, tga_palette, tga_palette_len * tga_comp) == 0)
					{
						CRuntime.free(tga_data);
						CRuntime.free(tga_palette);
						return (uint8*)(stbi__err("bad palette") != 0 ? (uint8*)null : null);
					}
				}

				for (i = 0; i < tga_width * tga_height; ++i)
				{
					if (tga_is_RLE != 0)
					{
						if (RLE_count == 0)
						{
							var RLE_cmd = (int)stbi__get8(s);
							RLE_count = 1 + (RLE_cmd & 127);
							RLE_repeating = RLE_cmd >> 7;
							read_next_pixel = 1;
						}
						else if (RLE_repeating == 0)
						{
							read_next_pixel = 1;
						}
					}
					else
					{
						read_next_pixel = 1;
					}

					if (read_next_pixel != 0)
					{
						if (tga_indexed != 0)
						{
							var pal_idx = tga_bits_per_pixel == 8 ? stbi__get8(s) : stbi__get16le(s);
							if (pal_idx >= tga_palette_len)
								pal_idx = 0;
							pal_idx *= tga_comp;
							for (j = 0; j < tga_comp; ++j)
								raw_data[j] = tga_palette[pal_idx + j];
						}
						else if (tga_rgb16 != 0)
						{
							stbi__tga_read_rgb16(s, raw_data);
						}
						else
						{
							for (j = 0; j < tga_comp; ++j)
								raw_data[j] = stbi__get8(s);
						}

						read_next_pixel = 0;
					}

					for (j = 0; j < tga_comp; ++j)
						tga_data[i * tga_comp + j] = raw_data[j];
					--RLE_count;
				}

				if (tga_inverted != 0)
					for (j = 0; j * 2 < tga_height; ++j)
					{
						var index1 = j * tga_width * tga_comp;
						var index2 = (tga_height - 1 - j) * tga_width * tga_comp;
						for (i = tga_width * tga_comp; i > 0; --i)
						{
							var temp = tga_data[index1];
							tga_data[index1] = tga_data[index2];
							tga_data[index2] = temp;
							++index1;
							++index2;
						}
					}

				if (tga_palette != null)
					CRuntime.free(tga_palette);
			}

			if (tga_comp >= 3 && tga_rgb16 == 0)
			{
				var tga_pixel = tga_data;
				for (i = 0; i < tga_width * tga_height; ++i)
				{
					var temp = tga_pixel[0];
					tga_pixel[0] = tga_pixel[2];
					tga_pixel[2] = temp;
					tga_pixel += tga_comp;
				}
			}

			if (req_comp != 0 && req_comp != tga_comp)
				tga_data = stbi__convert_format(tga_data, tga_comp, req_comp, (uint)tga_width, (uint)tga_height);
			tga_palette_start = tga_palette_len = tga_palette_bits = tga_x_origin = tga_y_origin = 0;
			return tga_data;
		}
	}
}