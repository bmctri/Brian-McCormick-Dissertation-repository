


import pandas as pd
import matplotlib.pyplot as plt
from PIL import Image

#removed Scot PArli iimage from plot.
# Load the image and remove the background
#logo_path = "F:\diss copy\dissertation\Dissertation data\images_dis\Scottish Parliament logo.png"
#logo = Image.open(logo_path)
#logo = logo.convert("RGBA")
#datas = logo.getdata()

#new_data = []
#for item in datas:
    # Change all white (also shades of whites) to transparent
  #  if item[0] in list(range(200, 256)):
  #      new_data.append((255, 255, 255, 0))
  #  else:
  #      new_data.append(item)

#logo.putdata(new_data)

years = [
    1978, 1981, 1982, 1989, 1990, 1994, 1995, 1995, 1995, 1997, 1999, 2001, 2002, 2002, 
    2003, 2003, 2003, 2004, 2005, 2006, 2007, 2007, 2007, 2010, 2010, 2010, 2011, 2011, 
    2011, 2011, 2011, 2011, 2012, 2012, 2012, 2013, 2014, 2014, 2014, 2014, 2014, 2014, 
    2014, 2014, 2014, 2015, 2015, 2015, 2015, 2015, 2015, 2015, 2016, 2016, 2016, 2016, 
    2016, 2016, 2016, 2016, 2016, 2017, 2017, 2017, 2017, 2018, 2018, 2018, 2018, 2018, 
    2019, 2019, 2019, 2019, 2019, 2019, 2020, 2020, 2020, 2021, 2021, 2021, 2022, 2022, 
    2022, 2022, 2022, 2022, 2023, 2023, 2023, 2024, 2024, 2024, 2024, 2024
]

# Convert the list into a DataFrame
data = pd.DataFrame(years, columns=['year'])

# Remove any data prior to 1999
data = data[data['year'] >= 1999]

# Calculate the cumulative count of legislations
data['cumulative_count'] = data['year'].rank(method='first').astype(int)

# Create plot
plt.figure(figsize=(14, 8))
plt.hist(data['year'], bins=range(data['year'].min(), data['year'].max() + 2), color='slategray', edgecolor='black', align='left')
plt.plot(data['year'], data['cumulative_count'], marker='o', linestyle='-', color='purple')

# Add a label to the cumulative count line
midpoint = len(data) // 2
plt.annotate('Cumulative Count', xy=(data['year'].iloc[midpoint], data['cumulative_count'].iloc[midpoint]), xytext=(data['year'].iloc[midpoint] + 2, data['cumulative_count'].iloc[midpoint] - 5),
             arrowprops=dict(facecolor='black', shrink=0.15), fontsize=15, color='black')
plt.xlabel('Year', fontsize=14)
plt.ylabel('Number of Legislations Mentioning Wellbeing', fontsize=14)
plt.title('Distribution of Legislations by Year', fontsize=16)
plt.xticks(range(data['year'].min(), data['year'].max() + 1), rotation=45, fontsize=12)
plt.yticks(fontsize=12)


plt.grid(axis='y', linestyle='--', alpha=0.7)


plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

# Add text box with source
source_text = "Source:\nhttps://uk.westlaw.com/SharedLink/5ce779e8114e41ba9a1520b9942319cb?VR=3.0&RS=cblt1.0"
plt.text(0.01, 0.98, source_text, fontsize=10, verticalalignment='top', transform=plt.gca().transAxes, bbox=dict(facecolor='white', alpha=0.5))

# Add the logo image  - ignore this#
#imagebox = plt.gca().inset_axes([0.01, 0.02, 0.1, 0.2], transform=plt.gca().transAxes)  # Adjust position and size
#imagebox.imshow(logo)
#imagebox.axis('off')

# Show the plot
plt.tight_layout()
plt.show()







