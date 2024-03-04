## How to contribute to the book

### Prerequisites:
- A python 3.6 or 3.7 installation https://www.python.org/downloads/

### Steps: 
1. Create a virtual environment. 
On Linux, by running in a terminal:
```
# This line creates a virtual environment called 'venv'
python3 -m venv venv 
# This line activates the virtual environment 
source venv/bin/activate 
```

On Windows, running in a terminal:
```
python -m venv venv
.\venv\Scripts\activate
```
2. Install the requirements found in book/requirements.txt
```
pip install -r .\book\requirements.txt
```

3. Add a new file (.md or .ipynb ) in book/ or update an existing one. 
If you add a new file, make sure to update the _toc.yml to include it in the table of contents

Then, built the new content by running:
```
jupyter-book build .\book\
```

4. Test the output by opening `_build\html\index.html`

5. Commit your changes.

6. Run `ghp-import -n -p -f _build/html` to deploy them to the website.