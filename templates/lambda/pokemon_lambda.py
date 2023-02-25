import json
import urllib.request
import random

def lambda_handler(event, context):
    favorite_pokemon = ["charmander", "pikachu", "slowpoke", "squirtle", "zapdos"]
    results = {}
    happiness = []

    for name in favorite_pokemon:

        #Retrieve base attributes from the /pokemon/{name} api
        base_url = f"https://pokeapi.co/api/v2/pokemon/{name}"
        base_req = urllib.request.Request(base_url)
        base_req.add_header('User-Agent', 'cheese')
        with urllib.request.urlopen(base_req) as base_response:
            base_data = json.loads(base_response.read().decode())

        # Retrieve "order" from the base attribute of the pokemon,
        # then call the /pokemon-species/{order} api to retrieve happiness/color
        order = base_data["order"]
        species_url = f"https://pokeapi.co/api/v2/pokemon-species/{order}"
        species_req = urllib.request.Request(species_url)
        species_req.add_header('User-Agent', 'cheese')
        with urllib.request.urlopen(species_req) as species_response:
            species_data = json.loads(species_response.read().decode())

        # Create a map of all requested attributes, and add it to the results map
        attributes = {
            "name": base_data["name"],
            "height": base_data["height"],
            "weight": base_data["weight"],
            "color": species_data["color"]["name"],
            "moves": random.sample([m["move"]["name"] for m in base_data["moves"]], k=2),
            "base_happiness": species_data["base_happiness"]
        }
        happiness.append(species_data["base_happiness"])
        results[name] = attributes

    # Happiness average calculation
    happiness_average = sum(happiness) / len(happiness)

    # Happiness median calculation
    sorted_happiness = sorted(happiness)
    if(len(sorted_happiness) % 2 == 0):
        # If the length of the array is even, take the average of the two middle values
        happiness_median = (sorted_happiness[len(sorted_happiness)//2 - 1] + sorted_happiness[len(sorted_happiness)//2]) / 2
    else:
        # If the length of the array is odd, take the middle value
        happiness_median = sorted_happiness[len(sorted_happiness)//2]

    # Add average/median happiness to results, and return
    results["average_base_happiness"] = happiness_average
    results["median_base_happiness"] = happiness_median
    return {
        'statusCode': 200,
        'body': json.dumps(results)
    }
