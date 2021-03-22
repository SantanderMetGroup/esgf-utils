import sys, os
import json
import tables

def parse_args(argv):
    args = {
        'col_size': 1000,
        'columns': None,
        'dest': None,
        'expectedrows': 10_000_000,
        'from': sys.stdin,
        'indexes': [],
        'table_name': 'files',
    }

    pos = 1
    arguments = len(argv) - 1
    if arguments < 1:
        print('Wrong usage, exiting...', file=sys.stderr)
        sys.exit(1)

    while arguments >= pos:
        if argv[pos] == '--col-size':
            args['col_size'] = int(argv[pos+1])
            pos+=2
        elif argv[pos] == '--columns':
            args['columns'] = argv[pos+1].split(',')
            pos+=2
        elif argv[pos] == '--expectedrows':
            args['expectedrows'] = int(argv[pos+1])
            pos+=2
        elif argv[pos] == '-f' or argv[pos] == '--from':
            args['from'] = argv[pos+1]
            pos+=2
        elif argv[pos] == '-h' or argv[pos] == '--help':
            print('''
store.py [OPTIONS] DEST

Store JSON objects from esgf-search into PyTables.

Options:
    --col-size N                Number of characters of the String column.
    --columns COLUMNS           Comma separated names for columns, default is to use JSON keys.
    --expectedrows N            Default is 10_000_000.
    --from FILE                 Read from FILE instead of stdin.
    --indexes INDEXES           Comma separated columns where indexes will be created.
    --table-name NAME           HDF5 name of the object where the Table will be created, default is '/files'.''', file=sys.stderr)
            sys.exit(1)
        elif argv[pos] == '--indexes':
            args['indexes'] = argv[pos+1].split(',')
            pos+=2
        elif argv[pos] == '--table-name':
            args['table_name'] = argv[pos+1]
            pos+=2
        else:
            args['dest'] = argv[pos]
            pos+=1

    return args

def read(f):
    if f is not sys.stdin:
        fh = open(f, 'r')
    else:
        fh = sys.stdin

    for line in fh:
        yield line.rstrip('\n')

    fh.close()

def append(item, row, columns):
    for c in columns:
        row[c] = item[c]
    row.append()

def main(f, args):
    # Get table columns from first json object
    gen = read(args['from'])
    first = json.loads( next(gen) )
    columns = first.keys()
    nkeys = len(columns)
    schema = dict(zip(columns, [tables.StringCol(args['col_size'])]*nkeys))

    # If columns passed as arguments, override
    if args['columns'] is not None:
        columns = args['columns']
        schema = dict(zip(args['columns'], [tables.StringCol(args['col_size'])]*len(args['columns'])))

    # Create PyTable's table
    filt = tables.Filters(complevel=1, shuffle=True)
    table = f.create_table(f.root, args['table_name'], schema, args['table_name'], filters=filt, expectedrows=args['expectedrows'])
    
    # Populate table, need to insert element obtained before
    row = table.row
    append(first, row, columns)
    for line in gen:
        d = json.loads(line)
        append(d, row, columns)
    
    table.flush()
    
    # Index table
    for i in args['indexes']:
        table.colinstances[eva_aggregation].create_csindex()
    
    f.flush()

if __name__ == '__main__':
    args = parse_args(sys.argv)
    
    if args['dest'] is None:
        print('Please, provide a file name destination, exiting...', file=sys.stderr)
        sys.exit(1)

    try:
        f = tables.open_file(args['dest'], mode='w')
        main(f, args)
    finally:
        f.close()
