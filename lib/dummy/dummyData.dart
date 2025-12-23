import 'dart:convert';

Map<String, dynamic> apiResponse = jsonDecode('''
{
  "status": "ok",
  "totalResults": 2,
  "articles": [
        {
            "source": {
                "id": "the-verge",
                "name": "The Verge"
            },
            "author": "Brandon Russell",
            "title": "The AirPods Pro 3 just dropped below \$200 for the first time",
            "description": "Apple’s latest gadgets have gotten some notable discounts lately — including the recently released Apple Watch Series 11, which is still on sale for \$100 off at Amazon. Now, we’re seeing the AirPods Pro 3 drop down to their lowest price to date, with the nois…",
            "url": "https://www.theverge.com/gadgets/842551/apple-airpods-pro-3-wireless-earbuds-deal-sale-2025",
            "urlToImage": "https://platform.theverge.com/wp-content/uploads/sites/2/2025/09/257943_Airpods_Pro3_AKrales_0103.jpg?quality=90&strip=all&crop=0%2C10.732984293194%2C100%2C78.534031413613&w=1200",
            "publishedAt": "2025-12-11T17:18:24Z",
            "content": "The discount is available at both Amazon and Walmart. The discount is available at both Amazon and Walmart."
        },
        {
            "source": {
                "id": "the-verge",
                "name": "The Verge"
            },
            "author": "Stevie Bonifield",
            "title": "Fortnite is back in Google’s Android app store",
            "description": "Fortnite players on Android devices in the US can once again download the game directly from the Google Play Store, not long after it returned to Apple's App Store in May. Its return comes five years after it was removed from Google's app store as Epic Games …",
            "url": "https://www.theverge.com/news/842855/fortnite-android-google-play",
            "urlToImage": "https://platform.theverge.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/25047547/236883_Epic_Vs_Google_B_CVirginia.jpg?quality=90&strip=all&crop=0%2C10.732984293194%2C100%2C78.534031413613&w=1200",
            "publishedAt": "2025-12-11T20:00:28Z",
            "content": "Fortnite players on Android devices in the US can once again download the game directly from the Google Play Store, not long after it returned to Apple's App Store in May. Its return comes five years…"
        }]
        }
''');