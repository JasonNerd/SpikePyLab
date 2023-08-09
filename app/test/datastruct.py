def test():
    a = {127: {0, 1, 2}, 3: {0, 1}}
    for k in a.keys():
        a[k] = list(a[k])
    print(a)


if __name__ == '__main__':
    test()


