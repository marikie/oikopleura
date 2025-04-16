from dataclasses import dataclass


@dataclass
class SbstRecord:
    sbstType: str
    chrA: str
    startA: int
    endA: int
    strandA: str
    trinucA: str
    chrB: str
    startB: int
    endB: int
    strandB: str
    trinucB: str
    chrC: str
    startC: int
    endC: int
    strandC: str
    trinucC: str
