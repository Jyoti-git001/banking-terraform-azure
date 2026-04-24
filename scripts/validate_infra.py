# simple script to check my azure resources exist after terraform apply

import subprocess
import sys
import argparse

def check(env):
    rg = f"banking-{env}-rg"
    print(f"\nChecking resources in: {rg}\n")

    # check resource group
    result = subprocess.run(
        ["az", "group", "show", "--name", rg],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print("Resource group exists")
    else:
        print("Resource group NOT found!")
        sys.exit(1)

    # check virtual machine
    result = subprocess.run(
        ["az", "vm", "show", "--resource-group", rg, "--name", f"banking-{env}-vm"],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print("VM exists")
    else:
        print("VM NOT found!")
        sys.exit(1)

    # check sql server
    result = subprocess.run(
        ["az", "sql", "server", "show", "--resource-group", rg, "--name", f"banking-{env}-sql"],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print("SQL Server exists")
    else:
        print("SQL Server NOT found!")
        sys.exit(1)

    print("\nAll checks passed!")

parser = argparse.ArgumentParser()
parser.add_argument("--env", required=True)
args = parser.parse_args()
check(args.env)
