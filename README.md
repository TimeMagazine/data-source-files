# Data Source Files

We often spend a lot of time cleaning up data sources to be presentable. For any reasonably important, reusable source, let's use this repository to story BOTH the original, *unmodified* data and the code we use to clean it.

Every data source should have it's own directory with two subdirectory: `data`, for the original, untouched files, and `clean` for the transmuted files we use in interactives. For large or frequently changing data sources, `data` can get contain a Markdown file with the appropriate `wget` commands or instructions on where to find the origin data.

Any code you write to clean up the data goes in the main directory for that dataset. For example, see my (tedious) R scripts for compiling DoD's data on active-duty military personnel.

Each source should have it's own, clearly named folder, with a README.md in that folder briefly detailing the data, the source, and a link. **Note:** Please initial and date this README so that we know who to bother when it breaks.

## Bonus: Datasets We May Want to Use Later

I find that I often come across caches of reliable, granular data when searching for something that are not immediately relevant but could be useful for a future idea. Please add anything you come across to the this repo in its own directory as well.