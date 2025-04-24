#!/usr/bin/env python3
"""
Script to load ENS events data into ClickHouse for testing the key/value mapping.
"""

import json
import datetime
import argparse
import clickhouse_driver

def parse_args():
    parser = argparse.ArgumentParser(description='Load ENS events into ClickHouse')
    parser.add_argument('--input', '-i', required=True, help='Input JSON file with ENS events')
    parser.add_argument('--host', default='localhost', help='ClickHouse host')
    parser.add_argument('--port', default=9000, type=int, help='ClickHouse port')
    parser.add_argument('--user', default='default', help='ClickHouse user')
    parser.add_argument('--password', default='password', help='ClickHouse password')
    parser.add_argument('--database', default='ens', help='ClickHouse database')
    parser.add_argument('--dry-run', action='store_true', help='Parse data but do not insert into ClickHouse')
    return parser.parse_args()

def main():
    args = parse_args()
    
    # Connect to ClickHouse
    if not args.dry_run:
        print(f"Connecting to ClickHouse at {args.host}:{args.port}")
        client = clickhouse_driver.Client(
            host=args.host, 
            port=args.port,
            user=args.user,
            password=args.password, 
            database=args.database
        )
    
    # Load the JSON file
    print(f"Loading events from {args.input}")
    with open(args.input, 'r') as f:
        lines = f.readlines()
    
    # Parse each line as a separate JSON object
    ens_events = []
    for line in lines:
        if line.strip():
            try:
                ens_events.append(json.loads(line))
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON: {e}")
    
    print(f"Loaded {len(ens_events)} event objects")
    
    # Process events
    names = {}
    texts = {}
    
    for event_json in ens_events:
        # Collect all event types
        events = []
        for event_type in ['nameRegistered', 'nameRenewed', 'nameTransferred', 'newOwner', 
                          'newResolver', 'newTtl', 'transfer', 'addrChanged', 
                          'nameChanged', 'contenthashChanged', 'textChanged']:
            if event_type in event_json:
                events.extend(event_json[event_type])
        
        # Process each event
        for e in events:
            timestamp = datetime.datetime.fromtimestamp(int(e.get('timestamp', 0)))
            node = e.get('node', '')
            
            # Handle name registration events
            if 'name' in e and 'label' in e and 'owner' in e:  # NameRegistered event
                name = e.get('name', '')
                if name:
                    full_name = f"{name}.eth"
                    names[full_name] = {
                        'name': full_name,
                        'node': node,
                        'owner': e.get('owner', ''),
                        'address': '',  # Will be updated when address is set
                        'contenthash': '',
                        'created_at': timestamp,
                        'updated_at': timestamp
                    }
                    # Map node to name for future reference
                    if node:
                        names[node] = names[full_name]
            
            # Handle address changes
            elif 'address' in e and node:  # AddrChanged event
                if node in names:
                    names[node]['address'] = e.get('address', '')
                    names[node]['updated_at'] = timestamp
                else:
                    # Create a new record if we don't have one yet
                    names[node] = {
                        'name': '',  # Will be updated when name is set
                        'node': node,
                        'owner': '',
                        'address': e.get('address', ''),
                        'contenthash': '',
                        'created_at': timestamp,
                        'updated_at': timestamp
                    }
            
            # Handle name changes
            elif 'name' in e and node and not ('label' in e):  # NameChanged event
                name = e.get('name', '')
                if name and not name.endswith('.addr.reverse'):
                    if node in names:
                        names[node]['name'] = name
                        names[node]['updated_at'] = timestamp
                    else:
                        # Create a new record if we don't have one yet
                        names[node] = {
                            'name': name,
                            'node': node,
                            'owner': '',
                            'address': '',
                            'contenthash': '',
                            'created_at': timestamp,
                            'updated_at': timestamp
                        }
            
            # Handle contenthash changes
            elif 'hash' in e and node:  # ContenthashChanged event
                if node in names:
                    names[node]['contenthash'] = e.get('hash', '')
                    names[node]['updated_at'] = timestamp
            
            # Handle text record changes
            elif 'key' in e and 'value' in e and node:  # TextChanged event
                key = e.get('key', '')
                value = e.get('value', '')
                text_key = f"{node}:{key}"
                
                texts[text_key] = {
                    'node': node,
                    'key': key,
                    'value': value,
                    'name': names[node]['name'] if node in names else '',
                    'created_at': timestamp,
                    'updated_at': timestamp
                }
    
    # Prepare data for insertion
    name_records = []
    for data in names.values():
        # Skip entries that are just node references
        if not data.get('name') or len(data['node']) < 10:
            continue
        
        name_records.append({
            'name': data.get('name', ''),
            'node': data.get('node', ''),
            'owner': data.get('owner', ''),
            'address': data.get('address', ''),
            'contenthash': data.get('contenthash', ''),
            'created_at': data.get('created_at', datetime.datetime.now()),
            'updated_at': data.get('updated_at', datetime.datetime.now())
        })
    
    text_records = []
    for data in texts.values():
        if not data.get('name'):
            # Try to find the name from the names dictionary
            node = data.get('node', '')
            if node in names and names[node].get('name'):
                data['name'] = names[node]['name']
        
        text_records.append({
            'name': data.get('name', ''),
            'node': data.get('node', ''),
            'key': data.get('key', ''),
            'value': data.get('value', ''),
            'created_at': data.get('created_at', datetime.datetime.now()),
            'updated_at': data.get('updated_at', datetime.datetime.now())
        })
    
    print(f"Processed {len(name_records)} name records and {len(text_records)} text records")
    
    # Insert data into ClickHouse
    if not args.dry_run and name_records:
        print("Inserting name records into ClickHouse")
        client.execute(
            'INSERT INTO ens_names (name, node, owner, address, contenthash, created_at, updated_at) VALUES',
            name_records
        )
    
    if not args.dry_run and text_records:
        print("Inserting text records into ClickHouse")
        client.execute(
            'INSERT INTO ens_texts (name, node, key, value, created_at, updated_at) VALUES',
            text_records
        )
    
    print("Done!")

if __name__ == "__main__":
    main()
