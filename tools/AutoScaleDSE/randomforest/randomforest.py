import pandas as pd

from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier





def main():


    pspace = pd.read_csv('TruePspace.csv', index_col=0)
    pspace["is_real"] = pd.NaT

    for i in range(len(pspace)):
        cycle = pspace.iloc[i]['cycle']
        lat = pspace.iloc[i]['latency'] * 100

        if (cycle * 0.95 < lat) and (lat < cycle * 1.05):
            pspace.at[i, 'is_real'] = True
        else:
            pspace.at[i, 'is_real'] = False

    pspace.to_csv('NewTruePspace.csv')

    tester = RandomForestRegressor(random_state=42)

    print(pspace[0][0:12])

    # tester.fit(pspace[0:12], lat[not_timeout])





























if __name__ == '__main__':
    main()

