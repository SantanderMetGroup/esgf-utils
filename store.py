import sys, os
import json
import tables

from config import projects

def parse_args(argv):
    args = {
        'col_size': 1000,
        'columns': ['id'],
        'dest': None,
        'expectedrows': 10_000_000,
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

def main(f, args):
    schema = dict(zip(args['columns'], [tables.StringCol(args['col_size'])]*len(args['columns'])))
    filt = tables.Filters(complevel=1, shuffle=True)
    table = f.create_table(f.root, args['table_name'], schema, args['table_name'], filters=filt, expectedrows=args['expectedrows'])
    
    # Populate table
    row = table.row
    for line in sys.stdin:
        d = json.loads(line.rstrip('\n'))
        for c in args['columns']:
            if c in d:
                row[c] = d[c]
        row.append()
    
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
