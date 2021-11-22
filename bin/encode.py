MAX_ROWS = 25
MAX_COLUMNS = 80

def get_ascii(fname):
    buf = ''
    with open(fname) as f:
        buf = f.read()

    return align_ascii(buf)

def align_ascii(buf):
    extra_rows = round((MAX_ROWS - buf.count('\n')) / 2)
    buf = ('\n' * extra_rows) + buf

    lines = buf.split('\n')
    max_len = max(len(l) for l in lines)

    extra_columns = (MAX_COLUMNS - max_len) // 2
    lines = [(' ' * extra_columns ) + l for l in lines]

    return '\n'.join(lines)

def get_lookup_table(ascii_buf):
    lookup_table = sorted(set(ascii_buf))
    lookup_table.remove(' ')
    lookup_table.insert(0, ' ')

    return ''.join(lookup_table)

def ascii_to_binary(ascii_buf, lookup_table):
    i, out = 0, []
    while i != len(ascii_buf):
        for l in range(MAX_COLUMNS-1):
            if ascii_buf[i]*l != ascii_buf[i:i+l]:
                break
        l -= 1

        if ascii_buf[i] == '\n':
            if len(out) & 1:
                out.append(0)
            out.append(0)
            out.append(0)
            i += 1
            continue

        if ascii_buf[i] == ' ':
            if len(out) & 1:
                out.append(0)
                l -= 1
                i += 1

            for x in range(0, l, 15):
                out.append(0)
                out.append(min(15, l-x))
            i += l
            continue

        idx = lookup_table.index(ascii_buf[i])
        out.extend([idx] * l)
        i += l

    idx, buf = 0, ''
    while idx != len(out):
        n1, n2 = out[idx+0], out[idx+1]
        buf += chr((n1 << 4) + n2)
        idx += 2

    return buf

if __name__ == '__main__':
    ascii_art = get_ascii('src/double_helix.txt')
    lookup_table = get_lookup_table(ascii_art)

    with open('lookup_table.bin', 'w') as f:
        f.write(lookup_table)

    with open('double_helix.bin', 'w') as f:
        f.write(ascii_to_binary(ascii_art, lookup_table))
