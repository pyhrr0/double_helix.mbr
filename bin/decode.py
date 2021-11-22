def decode_binary_blob(buf, lookup_table):
    out = b''
    for ch in buf:
        n1, n2 = ch >> 0x04, ch & 0x0f

        if ch == 0:
            out += b'\n'
            continue

        if not n1:
            out += b' ' * n2
            continue

        out += bytes((lookup_table[n1], lookup_table[n2]))

    print(out.decode('ascii'))

if __name__ == '__main__':
    logo = 'double_helix.bin'
    lookup_table = 'lookup_table.bin'

    with open(logo, 'rb') as f1:
        with open (lookup_table, 'rb') as f2:
            decode_binary_blob(f1.read(), f2.read())
