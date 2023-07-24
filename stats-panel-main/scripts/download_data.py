import osmnx as ox
ox.config(use_cache=True, log_console=True)

G = ox.graph_from_place("Veneto, Italy", network_type="walk",retain_all=True)

ox.save_graphml(G, filepath="Veneto.graphml")
