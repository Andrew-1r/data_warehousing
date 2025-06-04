from src.data import nested_loop_by_name as n, nested_loop_by_name_jaccard as j

def main():
    # Define data paths
    csv_path = "/home/s4828041/a2/a2t1/DataLinkage_py/data/restaurant.csv"
    benchmark_path = "/home/s4828041/a2/a2t1/DataLinkage_py/data/restaurant_pair.csv"
    # determines how many operations need to be one for one word
    # to be the same as another
    ed_threshold = 1

    # determines the size of the tokens the name is split into
    jac_q = 3

    # determines how similar the tokens have to be to each other based
    # on the jaccard coefficient
    jac_threshold = 0.75

    print("----- Edit Distance Similarity (takes about 10 seconds each time to run) -----")
    print("\nThreshold: ", ed_threshold)
    n.nested_loop_by_name(csv_path, benchmark_path, ed_threshold)

    ed_threshold = 2
    print("\nThreshold: ", ed_threshold)
    n.nested_loop_by_name(csv_path, benchmark_path, ed_threshold)

    ed_threshold = 3
    print("\nThreshold: ", ed_threshold)
    n.nested_loop_by_name(csv_path, benchmark_path, ed_threshold)

    ed_threshold = 4
    print("\nThreshold: ", ed_threshold)
    n.nested_loop_by_name(csv_path, benchmark_path, ed_threshold)

    ed_threshold = 5
    print("\nThreshold: ", ed_threshold)
    n.nested_loop_by_name(csv_path, benchmark_path, ed_threshold)

    print("\n----- Jaccard Coefficient Similarity -----")
    print("\nThreshold: ", jac_threshold)
    print("Q value: ", jac_q)
    j.nested_loop_by_name_jaccard(csv_path, benchmark_path, jac_q, jac_threshold)
    
    jac_q = 2
    print("\nThreshold: ", jac_threshold)
    print("Q value: ", jac_q)
    j.nested_loop_by_name_jaccard(csv_path, benchmark_path, jac_q, jac_threshold)

    jac_q = 1
    print("\nThreshold: ", jac_threshold)
    print("Q value: ", jac_q)
    j.nested_loop_by_name_jaccard(csv_path, benchmark_path, jac_q, jac_threshold)

    jac_q = 3
    jac_threshold = 0.5
    print("\nThreshold: ", jac_threshold)
    print("Q value: ", jac_q)
    j.nested_loop_by_name_jaccard(csv_path, benchmark_path, jac_q, jac_threshold)

    jac_threshold = 0.9
    print("\nThreshold: ", jac_threshold)
    print("Q value: ", jac_q)
    j.nested_loop_by_name_jaccard(csv_path, benchmark_path, jac_q, jac_threshold)

    jac_threshold = 1.0
    print("\nThreshold: ", jac_threshold)
    print("Q value: ", jac_q)
    j.nested_loop_by_name_jaccard(csv_path, benchmark_path, jac_q, jac_threshold)

if __name__ == "__main__":
    main()